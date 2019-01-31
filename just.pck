create or replace package Mt_Api is
  ----------------------------------------------------------------------------------------------------
  Procedure Device_Save(i_Device Mt_Devices%rowtype);
  ----------------------------------------------------------------------------------------------------
  Procedure User_Save_Device(i_User_Device Mt_User_Devices%rowtype);
  ----------------------------------------------------------------------------------------------------
  Procedure User_Delete_Device(i_User_Id number);
  ----------------------------------------------------------------------------------------------------
  Procedure Host_Save(i_Host Mt_Hosts%rowtype);
  ----------------------------------------------------------------------------------------------------
  Procedure Host_Delete(i_Host_Id number);
  ----------------------------------------------------------------------------------------------------
  Function Prepared_Host
  (
    i_User_Id   number,
    i_Token     varchar2,
    i_Device_Id number
  ) return number;
  ----------------------------------------------------------------------------------------------------
  Function Prepared_Device_Host
  (
    i_User_Id              number,
    i_Device_Name          varchar2,
    i_Device_Code          varchar2,
    i_Device_Version       varchar2,
    i_Device_Sdk           varchar2,
    i_Smartup_Version_Code number,
    i_Smartup_Version_Name varchar2,
    i_Device_Kind          varchar2,
    i_Token                varchar2
  ) return number;
  ----------------------------------------------------------------------------------------------------  
  Procedure Host_Entry_Id_Save
  (
    i_Host_Id  number,
    i_Entry_Id number
  );
  ----------------------------------------------------------------------------------------------------  
  Procedure Context_Id_Save
  (
    i_Code varchar2,
    i_Id   number
  );
  ----------------------------------------------------------------------------------------------------  
  Procedure Clear_Context_Id_Cache;
  ----------------------------------------------------------------------------------------------------  
  Procedure Route_History_Save(i_Route Mt_Route_Histories%rowtype);
  ----------------------------------------------------------------------------------------------------  
  Procedure Route_History_Delete(i_His_Id number);
end Mt_Api;
/
create or replace package body Mt_Api is

  g_Context_Ids_Cache Fazo.Number_Code_Aat;

  ----------------------------------------------------------------------------------------------------
  Function t
  (
    i_Message varchar2,
    i_P1      varchar2 := null,
    i_P2      varchar2 := null,
    i_P3      varchar2 := null,
    i_P4      varchar2 := null,
    i_P5      varchar2 := null
  ) return varchar2 is
  begin
    return b.Translate('MT:' || i_Message, i_P1, i_P2, i_P3, i_P4, i_P5);
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Device_Save(i_Device Mt_Devices%rowtype) is
  begin
    z_Mt_Devices.Save_Row(i_Row => i_Device);
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure User_Save_Device(i_User_Device Mt_User_Devices%rowtype) is
  begin
    z_Mt_User_Devices.Save_Row(i_Row => i_User_Device);
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure User_Delete_Device(i_User_Id number) is
  begin
    z_Mt_User_Devices.Delete_One(i_User_Id => i_User_Id);
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Host_Save(i_Host Mt_Hosts%rowtype) is
  begin
    z_Mt_Hosts.Save_Row(i_Row => i_Host);
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Host_Delete(i_Host_Id number) is
  begin
    z_Mt_Hosts.Delete_One(i_Host_Id => i_Host_Id);
  end;

  ----------------------------------------------------------------------------------------------------
  Function Prepared_Host
  (
    i_User_Id   number,
    i_Token     varchar2,
    i_Device_Id number
  ) return number is
    r_Host Mt_Hosts%rowtype;
  begin
    begin
      select t.*
        into r_Host
        from Mt_Hosts t
       where t.Token = i_Token;
    exception
      when No_Data_Found then
        null;
    end;
  
    if r_Host.Host_Id is null then
      r_Host.Host_Id   := Mt_Next.Host_Id;
      r_Host.User_Id   := i_User_Id;
      r_Host.Device_Id := i_Device_Id;
    else
      if r_Host.User_Id != i_User_Id or r_Host.Device_Id != i_Device_Id then
        b.Raise_Error(t('you logon with not registered device'));
      end if;
    end if;
  
    r_Host.Token      := Mt_Util.Get_New_Token(i_Host_Id => r_Host.Host_Id, --
                                               i_User_Id => i_User_Id);
    r_Host.Last_Seen  := sysdate;
    r_Host.Created_On := sysdate;
  
    Host_Save(i_Host => r_Host);
  
    return r_Host.Host_Id;
  end;

  ----------------------------------------------------------------------------------------------------
  Function Prepared_Device_Host
  (
    i_User_Id              number,
    i_Device_Name          varchar2,
    i_Device_Code          varchar2,
    i_Device_Version       varchar2,
    i_Device_Sdk           varchar2,
    i_Smartup_Version_Code number,
    i_Smartup_Version_Name varchar2,
    i_Device_Kind          varchar2,
    i_Token                varchar2
  ) return number is
    r_Device      Mt_Devices%rowtype;
    r_User_Device Mt_User_Devices%rowtype;
  begin
    begin
      select t.*
        into r_Device
        from Mt_Devices t
       where t.Device_Code = i_Device_Code
         and t.Device_Kind = i_Device_Kind;
    exception
      when No_Data_Found then
        null;
    end;
    if r_Device.Device_Id is null then
      Mt_Util.Check_User_Has_Device(i_User_Id => i_User_Id);
    
      -- create device
      r_Device.Device_Id            := Mt_Next.Device_Id;
      r_Device.Name                 := i_Device_Name;
      r_Device.Device_Code          := i_Device_Code;
      r_Device.Device_Version       := i_Device_Version;
      r_Device.Device_Sdk           := i_Device_Sdk;
      r_Device.Smartup_Version_Code := i_Smartup_Version_Code;
      r_Device.Smartup_Version_Name := i_Smartup_Version_Name;
      r_Device.Device_Kind          := i_Device_Kind;
      r_Device.State                := Mt_Pref.c_Ds_New;
    
      Mt_Api.Device_Save(i_Device => r_Device);
    
      -- create device user bind
      if not z_Mt_User_Devices.Exist(i_User_Id => i_User_Id) then
        r_User_Device.User_Id   := i_User_Id;
        r_User_Device.Device_Id := r_Device.Device_Id;
      
        Mt_Api.User_Save_Device(i_User_Device => r_User_Device);
      else
        b.Raise_Error(t('user already used'));
      end if;
    else
      r_Device.Name                 := i_Device_Name;
      r_Device.Device_Code          := i_Device_Code;
      r_Device.Device_Version       := i_Device_Version;
      r_Device.Device_Sdk           := i_Device_Sdk;
      r_Device.Smartup_Version_Code := i_Smartup_Version_Code;
      r_Device.Smartup_Version_Name := i_Smartup_Version_Name;
    
      Mt_Api.Device_Save(i_Device => r_Device);
    
      r_User_Device := z_Mt_User_Devices.Take(i_User_Id => i_User_Id);
    
      if r_Device.State = Mt_Pref.Ds_Passive then
        b.Raise_Error(t('Your device is blocked by Administrator'));
      end if;
    
      if r_User_Device.Device_Id is null then
        r_User_Device.User_Id   := i_User_Id;
        r_User_Device.Device_Id := r_Device.Device_Id;
      
        Mt_Api.User_Save_Device(i_User_Device => r_User_Device);
      
      elsif r_User_Device.Device_Id != r_Device.Device_Id then
        b.Raise_Error(t('you logon with not registered device'));
      end if;
    
    end if;
  
    return Prepared_Host(i_User_Id   => i_User_Id,
                         i_Token     => i_Token,
                         i_Device_Id => r_Device.Device_Id);
  end;

  ----------------------------------------------------------------------------------------------------  
  Procedure Host_Entry_Id_Save
  (
    i_Host_Id  number,
    i_Entry_Id number
  ) is
  begin
    z_Mt_Host_Entry_Ids.Insert_Try(i_Host_Id => i_Host_Id, i_Entry_Id => i_Entry_Id);
  end;

  ----------------------------------------------------------------------------------------------------  
  Procedure Context_Id_Save
  (
    i_Code varchar2,
    i_Id   number
  ) is
    v_Key varchar2(100) := i_Code || ':' || i_Id;
  begin
    if not g_Context_Ids_Cache.Exists(v_Key) then
      insert into Mt_Context_Ids
        (Code, Id)
      values
        (i_Code, i_Id);
      g_Context_Ids_Cache(v_Key) := 1;
    end if;
  end;
  ----------------------------------------------------------------------------------------------------  
  Procedure Clear_Context_Id_Cache is
  begin
    delete Mt_Context_Ids;
    g_Context_Ids_Cache.Delete;
  end;

  ----------------------------------------------------------------------------------------------------  
  Procedure Route_History_Save(i_Route Mt_Route_Histories%rowtype) is
  begin
    z_Mt_Route_Histories.Save_Row(i_Route);
  end;

  ----------------------------------------------------------------------------------------------------  
  Procedure Route_History_Delete(i_His_Id number) is
  begin
    z_Mt_Route_Histories.Delete_One(i_His_Id => i_His_Id);
  end;
end Mt_Api;
/
