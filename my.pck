create or replace package Md_Api is
  ----------------------------------------------------------------------------------------------------
  Function t
  (
    i_Message varchar2,
    i_P1      varchar2 := null,
    i_P2      varchar2 := null,
    i_P3      varchar2 := null,
    i_P4      varchar2 := null,
    i_P5      varchar2 := null
  ) return varchar2;
  ----------------------------------------------------------------------------------------------------
  Procedure Person_Save
  (
    i_Person_Id number,
    i_Name      varchar2,
    Is_Legal    boolean
  );
  ----------------------------------------------------------------------------------------------------
  Procedure Person_Delete(i_Person_Id number);
  ----------------------------------------------------------------------------------------------------
  Procedure Filial_Save(p_Filial in out Md_Filials%rowtype);
  ----------------------------------------------------------------------------------------------------
  Procedure Filial_Delete(i_Filial_Id number);
  ----------------------------------------------------------------------------------------------------
  Procedure User_Save(p_User in out Md_Users%rowtype);
  ----------------------------------------------------------------------------------------------------
  Procedure User_Delete(i_User_Id number);
  ----------------------------------------------------------------------------------------------------
  Procedure User_Add_Filial
  (
    i_User_Id   number,
    i_Filial_Id number
  );
  ----------------------------------------------------------------------------------------------------
  Procedure User_Remove_Filial
  (
    i_User_Id   number,
    i_Filial_Id number
  );
  ----------------------------------------------------------------------------------------------------
  Procedure User_Change_Password
  (
    i_User_Id                   number,
    i_Password                  varchar2,
    i_Password_Changed_On       date,
    i_Forced_To_Change_Password varchar2
  );
  ----------------------------------------------------------------------------------------------------
  Procedure User_Setting_Save
  (
    i_User_Id       number,
    i_Filial_Id     number,
    i_Setting_Code  varchar2,
    i_Setting_Value clob
  );
  ----------------------------------------------------------------------------------------------------
  Function User_Setting_Load
  (
    i_User_Id      number,
    i_Filial_Id    number,
    i_Setting_Code varchar2,
    i_Defaul_Value clob := null
  ) return clob;
  ----------------------------------------------------------------------------------------------------
  Procedure User_Settings_Clear
  (
    i_User_Id      number,
    i_Filial_Id    number,
    i_Package_Code varchar2
  );
  ----------------------------------------------------------------------------------------------------
  Procedure Role_Save(i_Role Md_Roles%rowtype);
  ----------------------------------------------------------------------------------------------------
  Procedure Role_Delete(i_Role_Id number);
  ----------------------------------------------------------------------------------------------------
  Procedure Role_Grant
  (
    i_User_Id   number,
    i_Filial_Id number,
    i_Role_Id   number
  );
  ----------------------------------------------------------------------------------------------------
  Procedure Role_Revoke
  (
    i_Filial_Id number,
    i_User_Id   number,
    i_Role_Id   number
  );
  ----------------------------------------------------------------------------------------------------
  Procedure Form_Grant
  (
    i_Role_Id number,
    i_Form    varchar2
  );
  ----------------------------------------------------------------------------------------------------
  Procedure Form_Grant
  (
    i_User_Id   number,
    i_Filial_Id number,
    i_Form      varchar2
  );
  ----------------------------------------------------------------------------------------------------
  Procedure Form_Revoke
  (
    i_Role_Id number,
    i_Form    varchar2
  );
  ----------------------------------------------------------------------------------------------------
  Procedure Form_Revoke
  (
    i_User_Id   number,
    i_Filial_Id number,
    i_Form      varchar2
  );
  ----------------------------------------------------------------------------------------------------
  Procedure Form_Action_Grant
  (
    i_Role_Id    number,
    i_Form       varchar2,
    i_Action_Key varchar2
  );
  ----------------------------------------------------------------------------------------------------
  Procedure Form_Action_Grant
  (
    i_User_Id    number,
    i_Filial_Id  number,
    i_Form       varchar2,
    i_Action_Key varchar2
  );
  ----------------------------------------------------------------------------------------------------
  Procedure Form_Action_Revoke
  (
    i_Role_Id    number,
    i_Form       varchar2,
    i_Action_Key varchar2
  );
  ----------------------------------------------------------------------------------------------------
  Procedure Form_Action_Revoke
  (
    i_User_Id    number,
    i_Filial_Id  number,
    i_Form       varchar2,
    i_Action_Key varchar2
  );
  ----------------------------------------------------------------------------------------------------
  Procedure Menu_Grant
  (
    i_Role_Id          number,
    i_Menu_Code_Parent varchar2
  );
  ----------------------------------------------------------------------------------------------------
  Procedure Menu_Revoke
  (
    i_Role_Id          number,
    i_Menu_Code_Parent varchar2
  );
  ----------------------------------------------------------------------------------------------------
  Procedure Access_All_Forms_Generate
  (
    i_Role_Id number,
    i_User_Id number
  );
  ----------------------------------------------------------------------------------------------------
  Procedure Access_All_Forms_Remove
  (
    i_Role_Id number,
    i_User_Id number
  );
  ----------------------------------------------------------------------------------------------------
  Procedure Form_Favorite_Save
  (
    i_User_Id   number,
    i_Filial_Id number,
    i_Form_Url  varchar2,
    i_Form      varchar2,
    i_Order_No  number,
    i_Name      varchar2
  );
  ----------------------------------------------------------------------------------------------------
  Procedure Form_Favorite_Delete
  (
    i_User_Id   number,
    i_Filial_Id number,
    i_Form_Url  varchar2
  );
  ----------------------------------------------------------------------------------------------------
  Procedure Preference_Save_Head
  (
    i_Filial_Id number,
    i_Code      varchar2,
    i_Value     varchar2
  );

  ----------------------------------------------------------------------------------------------------
  Procedure Request_Form_Action_Save
  (
    i_Request_Id number,
    i_Filial_Id  number,
    i_User_Id    number,
    i_Form       varchar2,
    i_Action_Set varchar2,
    i_Created_On timestamp with local time zone,
    i_Note       varchar2
  );
  ----------------------------------------------------------------------------------------------------
  Procedure Request_Form_Action_Done(i_Request_Id number);
  ----------------------------------------------------------------------------------------------------
  Procedure Preference_Save_Filial
  (
    i_Filial_Id number,
    i_Code      varchar2,
    i_Value     varchar2
  );
  ----------------------------------------------------------------------------------------------------
  Procedure Preferences_Clear
  (
    i_Filial_Id    number,
    i_Package_Code varchar2
  );
  ----------------------------------------------------------------------------------------------------
  Procedure Sequence_Setval
  (
    i_Code  varchar2,
    i_Value number
  );
  ----------------------------------------------------------------------------------------------------
  Function Sequence_Curval(i_Code varchar2) return number;
  ----------------------------------------------------------------------------------------------------
  Function Sequence_Nextval(i_Code varchar2) return number;
  ----------------------------------------------------------------------------------------------------
  Procedure Session_Save(i_Session Md_Sessions%rowtype);
  ----------------------------------------------------------------------------------------------------
  Procedure Session_Add(i_Session Md_Sessions%rowtype);
  ----------------------------------------------------------------------------------------------------
  Procedure Session_Delete(i_Session_Id number);
  ----------------------------------------------------------------------------------------------------
  Procedure Custom_Form_Kind_Save
  (
    i_Form varchar2,
    i_Kind varchar2
  );
  ----------------------------------------------------------------------------------------------------
  Procedure Custom_Form_Kind_Delete(i_Form varchar2);

end Md_Api;
/
create or replace package body Md_Api is

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
    return b.Translate('MD:' || i_Message, i_P1, i_P2, i_P3, i_P4, i_P5);
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Person_Save
  (
    i_Person_Id number,
    i_Name      varchar2,
    Is_Legal    boolean
  ) is
    r_Person Md_Persons%rowtype;
    v_Pk     varchar2(1);
  begin
    if Is_Legal then
      v_Pk := Md_Pref.Pk_Legal;
    else
      v_Pk := Md_Pref.Pk_Natural;
    end if;

    r_Person.Person_Id   := i_Person_Id;
    r_Person.Name        := i_Name;
    r_Person.Person_Kind := v_Pk;

    z_Md_Persons.Save_Row(r_Person);
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Person_Delete(i_Person_Id number) is
  begin
    z_Md_Persons.Delete_One(i_Person_Id);
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Filial_Save(p_Filial in out Md_Filials%rowtype) is
    v_Not_Exist boolean;
  begin
    if p_Filial.Name is null then
      p_Filial.Name := z_Mr_Legal_Persons.Take(p_Filial.Filial_Id).Short_Name;
      if p_Filial.Name is null then
        b.Raise_Error(t('Legal person not found'));
      end if;
    end if;

    if not z_Md_Filials.Exist(p_Filial.Filial_Id) then
      v_Not_Exist := true;
    end if;

    z_Md_Filials.Save_Row(p_Filial);

    z_Md_User_Filials.Insert_Try(i_User_Id   => Md_Pref.c_User_Admin,
                                 i_Filial_Id => p_Filial.Filial_Id);

    Md_Core.Make_Dirty_User_Filial(i_User_Id   => Md_Pref.c_User_Admin,
                                   i_Filial_Id => p_Filial.Filial_Id);

    if v_Not_Exist then
      Md_Global.w_Filial_Id := p_Filial.Filial_Id;
      b.Notify_Watchers(i_Watching_Expr => 'md_global.w_filial_id', i_Expr_Type => 'number');
    end if;
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Filial_Delete(i_Filial_Id number) is
  begin
    if i_Filial_Id = Md_Pref.c_Filial_Head then
      b.Raise_Error(t('you can not delete head filial'));
    end if;

    delete Md_Gen_User_Form_Actions t
     where t.Filial_Id = i_Filial_Id;

    delete Md_Uf_Form_Actions t
     where t.Filial_Id = i_Filial_Id;

    z_Md_User_Filials.Delete_One(i_User_Id => Md_Pref.c_User_Admin, i_Filial_Id => i_Filial_Id);

    z_Md_Filials.Delete_One(i_Filial_Id);
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure User_Save(p_User in out Md_Users%rowtype) is
  begin
    if p_User.Name is null then
      p_User.Name := z_Md_Persons.Take(p_User.User_Id).Name;
      if p_User.Name is null then
        b.Raise_Error('Natural person not found');
      end if;
    end if;
    z_Md_Users.Save_Row(p_User);
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure User_Delete(i_User_Id number) is
  begin
    delete Md_Gen_User_Form_Actions t
     where t.User_Id = i_User_Id;

    delete from Md_Uf_Form_Actions t
     where t.User_Id = i_User_Id;

    delete Md_User_Filials t
     where t.User_Id = i_User_Id;

    delete Md_User_Roles t
     where t.User_Id = i_User_Id;

    z_Md_Users.Delete_One(i_User_Id);
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure User_Add_Filial
  (
    i_User_Id   number,
    i_Filial_Id number
  ) is
  begin
    z_Md_User_Filials.Insert_Try(i_User_Id => i_User_Id, i_Filial_Id => i_Filial_Id);
    Md_Core.Make_Dirty_User_Filial(i_User_Id => i_User_Id, i_Filial_Id => i_Filial_Id);
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure User_Remove_Filial
  (
    i_User_Id   number,
    i_Filial_Id number
  ) is
  begin
    delete from Md_User_Roles t
     where t.Filial_Id = i_Filial_Id
       and t.User_Id = i_User_Id;

    delete from Md_Uf_Form_Actions t
     where t.Filial_Id = i_Filial_Id
       and t.User_Id = i_User_Id;

    z_Md_User_Filials.Delete_One(i_User_Id => i_User_Id, i_Filial_Id => i_Filial_Id);

    Md_Core.Make_Dirty_User_Filial(i_User_Id => i_User_Id, i_Filial_Id => i_Filial_Id);
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure User_Change_Password
  (
    i_User_Id                   number,
    i_Password                  varchar2,
    i_Password_Changed_On       date,
    i_Forced_To_Change_Password varchar2
  ) is
  begin
    z_Md_Users.Update_One(i_User_Id                   => i_User_Id,
                          i_Password                  => Option_Varchar2(i_Password),
                          i_Forced_To_Change_Password => Option_Varchar2(i_Forced_To_Change_Password),
                          i_Password_Changed_On       => Option_Date(i_Password_Changed_On));
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure User_Setting_Save
  (
    i_User_Id       number,
    i_Filial_Id     number,
    i_Setting_Code  varchar2,
    i_Setting_Value clob
  ) is
  begin
    z_Md_User_Settings.Save_One(i_User_Id       => i_User_Id,
                                i_Filial_Id     => i_Filial_Id,
                                i_Setting_Code  => i_Setting_Code,
                                i_Setting_Value => i_Setting_Value);
  end;

  ----------------------------------------------------------------------------------------------------
  Function User_Setting_Load
  (
    i_User_Id      number,
    i_Filial_Id    number,
    i_Setting_Code varchar2,
    i_Defaul_Value clob := null
  ) return clob is
    r_Data Md_User_Settings%rowtype;
  begin
    if z_Md_User_Settings.Exist(i_User_Id      => i_User_Id,
                                i_Filial_Id    => i_Filial_Id,
                                i_Setting_Code => i_Setting_Code,
                                o_Row          => r_Data) then
      return r_Data.Setting_Value;
    end if;

    return i_Defaul_Value;
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure User_Settings_Clear
  (
    i_User_Id      number,
    i_Filial_Id    number,
    i_Package_Code varchar2
  ) is
    v_Setting_Code_Like varchar2(50) := i_Package_Code || ':%';
  begin
    for r in (select *
                from Md_User_Settings u
               where u.User_Id = i_User_Id
                 and u.Filial_Id = i_Filial_Id
                 and Lower(u.Setting_Code) like Lower(v_Setting_Code_Like))
    loop
      z_Md_User_Settings.Delete_One(i_User_Id      => i_User_Id,
                                    i_Filial_Id    => i_Filial_Id,
                                    i_Setting_Code => r.Setting_Code);
    end loop;

  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Role_Save(i_Role Md_Roles%rowtype) is
    r_Data Md_Roles%rowtype;
  begin
    if z_Md_Roles.Exist(i_Role.Role_Id, r_Data) then
      if r_Data.Pcode is not null then
        b.Raise_Fatal('MD: Role is readonly, role_id = $1', i_Role.Role_Id);
      end if;
    end if;

    z_Md_Roles.Save_Row(i_Role);
    Md_Core.Make_Dirty_Role(i_Role_Id => i_Role.Role_Id);
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Role_Delete(i_Role_Id number) is
    r_Data Md_Roles%rowtype;
  begin
    if z_Md_Roles.Exist(i_Role_Id, r_Data) then
      if r_Data.Pcode is not null then
        b.Raise_Fatal('MD: Role is readonly, role_id = $1', i_Role_Id);
      end if;
    end if;

    delete from Md_Role_Form_Actions t
     where t.Role_Id = i_Role_Id;

    z_Md_Roles.Delete_One(i_Role_Id => i_Role_Id);
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Role_Grant
  (
    i_User_Id   number,
    i_Filial_Id number,
    i_Role_Id   number
  ) is
  begin
    z_Md_User_Roles.Insert_Try(i_User_Id   => i_User_Id,
                               i_Filial_Id => i_Filial_Id,
                               i_Role_Id   => i_Role_Id);
    Md_Core.Make_Dirty_User_Filial(i_User_Id => i_User_Id, i_Filial_Id => i_Filial_Id);
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Role_Revoke
  (
    i_Filial_Id number,
    i_User_Id   number,
    i_Role_Id   number
  ) is
  begin
    z_Md_User_Roles.Delete_One(i_Filial_Id => i_Filial_Id,
                               i_User_Id   => i_User_Id,
                               i_Role_Id   => i_Role_Id);

    Md_Core.Make_Dirty_User_Filial(i_User_Id => i_User_Id, i_Filial_Id => i_Filial_Id);
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Form_Grant
  (
    i_Role_Id number,
    i_Form    varchar2
  ) is
  begin
    z_Md_Role_Form_Actions.Insert_Try(i_Role_Id    => i_Role_Id,
                                      i_Form       => i_Form,
                                      i_Action_Key => Md_Pref.c_Form_Sign);
    Md_Core.Make_Dirty_Role(i_Role_Id => i_Role_Id);
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Form_Grant
  (
    i_User_Id   number,
    i_Filial_Id number,
    i_Form      varchar2
  ) is
  begin
    z_Md_Uf_Form_Actions.Insert_Try(i_User_Id    => i_User_Id,
                                    i_Filial_Id  => i_Filial_Id,
                                    i_Form       => i_Form,
                                    i_Action_Key => Md_Pref.c_Form_Sign);
    Md_Core.Make_Dirty_User_Filial(i_User_Id => i_User_Id, i_Filial_Id => i_Filial_Id);
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Form_Revoke
  (
    i_Role_Id number,
    i_Form    varchar2
  ) is
  begin
    z_Md_Role_Form_Actions.Delete_One(i_Role_Id    => i_Role_Id,
                                      i_Form       => i_Form,
                                      i_Action_Key => Md_Pref.c_Form_Sign);
    Md_Core.Make_Dirty_Role(i_Role_Id => i_Role_Id);
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Form_Revoke
  (
    i_User_Id   number,
    i_Filial_Id number,
    i_Form      varchar2
  ) is
  begin
    z_Md_Uf_Form_Actions.Delete_One(i_User_Id    => i_User_Id,
                                    i_Filial_Id  => i_Filial_Id,
                                    i_Form       => i_Form,
                                    i_Action_Key => Md_Pref.c_Form_Sign);
    Md_Core.Make_Dirty_User_Filial(i_User_Id => i_User_Id, i_Filial_Id => i_Filial_Id);
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Form_Action_Grant
  (
    i_Role_Id    number,
    i_Form       varchar2,
    i_Action_Key varchar2
  ) is
  begin
    z_Md_Role_Form_Actions.Insert_Try(i_Role_Id    => i_Role_Id,
                                      i_Form       => i_Form,
                                      i_Action_Key => i_Action_Key);
    Md_Core.Make_Dirty_Role(i_Role_Id => i_Role_Id);
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Form_Action_Grant
  (
    i_User_Id    number,
    i_Filial_Id  number,
    i_Form       varchar2,
    i_Action_Key varchar2
  ) is
  begin
    z_Md_Uf_Form_Actions.Insert_Try(i_User_Id    => i_User_Id,
                                    i_Filial_Id  => i_Filial_Id,
                                    i_Form       => i_Form,
                                    i_Action_Key => i_Action_Key);
    Md_Core.Make_Dirty_User_Filial(i_User_Id => i_User_Id, i_Filial_Id => i_Filial_Id);
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Form_Action_Revoke
  (
    i_Role_Id    number,
    i_Form       varchar2,
    i_Action_Key varchar2
  ) is
  begin
    z_Md_Role_Form_Actions.Delete_One(i_Role_Id    => i_Role_Id,
                                      i_Form       => i_Form,
                                      i_Action_Key => i_Action_Key);
    Md_Core.Make_Dirty_Role(i_Role_Id => i_Role_Id);
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Form_Action_Revoke
  (
    i_User_Id    number,
    i_Filial_Id  number,
    i_Form       varchar2,
    i_Action_Key varchar2
  ) is
  begin
    z_Md_Uf_Form_Actions.Delete_One(i_User_Id    => i_User_Id,
                                    i_Filial_Id  => i_Filial_Id,
                                    i_Form       => i_Form,
                                    i_Action_Key => i_Action_Key);
    Md_Core.Make_Dirty_User_Filial(i_User_Id => i_User_Id, i_Filial_Id => i_Filial_Id);
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Menu_Grant
  (
    i_Role_Id          number,
    i_Menu_Code_Parent varchar2
  ) is
  begin
    z_Md_Role_Menus.Insert_Try(i_Role_Id => i_Role_Id, i_Menu_Code_Parent => i_Menu_Code_Parent);
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Menu_Revoke
  (
    i_Role_Id          number,
    i_Menu_Code_Parent varchar2
  ) is
  begin
    z_Md_Role_Menus.Delete_One(i_Role_Id => i_Role_Id, i_Menu_Code_Parent => i_Menu_Code_Parent);
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Access_All_Forms_Generate
  (
    i_Role_Id number,
    i_User_Id number
  ) is
  begin
    Md_Core.Access_All_Forms_Generate(i_Role_Id, i_User_Id);
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Access_All_Forms_Remove
  (
    i_Role_Id number,
    i_User_Id number
  ) is
  begin
    Md_Core.Access_All_Forms_Remove(i_Role_Id, i_User_Id);
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Form_Favorite_Save
  (
    i_User_Id   number,
    i_Filial_Id number,
    i_Form_Url  varchar2,
    i_Form      varchar2,
    i_Order_No  number,
    i_Name      varchar2
  ) is
  begin
    z_Md_Form_Favorites.Save_One(i_User_Id   => i_User_Id,
                                 i_Filial_Id => i_Filial_Id,
                                 i_Form_Url  => i_Form_Url,
                                 i_Form      => i_Form,
                                 i_Order_No  => i_Order_No,
                                 i_Name      => i_Name);
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Form_Favorite_Delete
  (
    i_User_Id   number,
    i_Filial_Id number,
    i_Form_Url  varchar2
  ) is
  begin
    z_Md_Form_Favorites.Delete_One(i_User_Id   => i_User_Id,
                                   i_Filial_Id => i_Filial_Id,
                                   i_Form_Url  => i_Form_Url);
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Request_Form_Action_Save
  (
    i_Request_Id number,
    i_Filial_Id  number,
    i_User_Id    number,
    i_Form       varchar2,
    i_Action_Set varchar2,
    i_Created_On timestamp with local time zone,
    i_Note       varchar2
  ) is
  begin
    z_Md_Request_Form_Actions.Save_One(i_Request_Id => i_Request_Id,
                                       i_Filial_Id  => i_Filial_Id,
                                       i_User_Id    => i_User_Id,
                                       i_Form       => i_Form,
                                       i_Action_Set => i_Action_Set,
                                       i_State      => Md_Pref.Rs_Waiting,
                                       i_Created_On => i_Created_On,
                                       i_Note       => i_Note);
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Request_Form_Action_Done(i_Request_Id number) is
  begin
    z_Md_Request_Form_Actions.Update_One(i_Request_Id => i_Request_Id,
                                         i_State      => Option_Varchar2(Md_Pref.Rs_Done));
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Preference_Save_Head
  (
    i_Filial_Id number,
    i_Code      varchar2,
    i_Value     varchar2
  ) is
    r Md_Preferences%rowtype;
  begin
    if z_Md_Preferences.Take(i_Filial_Id, i_Code).Pref_Access = Md_Pref.c_Pa_System then
      b.Raise_Error(t('Head can not change system preferences'));
    end if;

    if i_Value is null then
      z_Md_Preferences.Delete_One(i_Filial_Id => i_Filial_Id, i_Pref_Code => i_Code);
    else
      r.Filial_Id   := i_Filial_Id;
      r.Pref_Code   := i_Code;
      r.Pref_Access := Md_Pref.c_Pa_Head;
      r.Pref_Value  := i_Value;
      z_Md_Preferences.Save_Row(r);
    end if;
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Preference_Save_Filial
  (
    i_Filial_Id number,
    i_Code      varchar2,
    i_Value     varchar2
  ) is
    r Md_Preferences%rowtype;
  begin

    case z_Md_Preferences.Take(i_Filial_Id, i_Code).Pref_Access
      when Md_Pref.c_Pa_System then
        b.Raise_Error(t('Filial can not change system preferences'));
      when Md_Pref.c_Pa_Head then
        b.Raise_Error(t('Filial can not change head preferences'));
      else
        if i_Value is null then
          z_Md_Preferences.Delete_One(i_Filial_Id => i_Filial_Id, i_Pref_Code => i_Code);
        else
          r.Filial_Id   := i_Filial_Id;
          r.Pref_Code   := i_Code;
          r.Pref_Access := Md_Pref.c_Pa_Filial;
          r.Pref_Value  := i_Value;
          z_Md_Preferences.Save_Row(r);
        end if;

    end case;

  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Preferences_Clear
  (
    i_Filial_Id    number,
    i_Package_Code varchar2
  ) is
    v_Pref_Code_Like varchar2(50) := i_Package_Code || ':%';
  begin
    for r in (select *
                from Md_Preferences t
               where Lower(t.Pref_Code) like Lower(v_Pref_Code_Like)
                 and t.Filial_Id = i_Filial_Id)
    loop
      z_Md_Preferences.Delete_One(i_Filial_Id => i_Filial_Id, i_Pref_Code => r.Pref_Code);
    end loop;
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Sequence_Setval
  (
    i_Code  varchar2,
    i_Value number
  ) is
  begin
    Md_Core.Sequence_Setval(i_Code, i_Value);
  end;

  ----------------------------------------------------------------------------------------------------
  Function Sequence_Curval(i_Code varchar2) return number is
  begin
    return Md_Core.Sequence_Curval(i_Code);
  end;
  ----------------------------------------------------------------------------------------------------  
  Function Sequence_Nextval(i_Code varchar2) return number is
  begin
    return Md_Core.Sequence_Nextval(i_Code);
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Session_Save(i_Session Md_Sessions%rowtype) is
  begin
    z_Md_Sessions.Save_Row(i_Session);
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Session_Add(i_Session Md_Sessions%rowtype) is
  begin
    z_Md_Sessions.Insert_Row(i_Session);
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Session_Delete(i_Session_Id number) is
  begin
    z_Md_Sessions.Delete_One(i_Session_Id);
  end;
  ----------------------------------------------------------------------------------------------------
  Procedure Custom_Form_Kind_Save
  (
    i_Form varchar2,
    i_Kind varchar2
  ) is
  begin
    z_Md_Custom_Form_Kinds.Save_One(i_Form => i_Form, i_Kind => i_Kind);
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Custom_Form_Kind_Delete(i_Form varchar2) is
  begin
    z_Md_Custom_Form_Kinds.Delete_One(i_Form => i_Form);
  end;

end Md_Api;
/
