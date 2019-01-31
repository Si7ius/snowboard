angular.module('app').controller('AppDev', function ($rootScope, $scope, bConfig, bFrame, bAlert, bHttp, $http, $q, $location, AppSession, $filter) {
  $rootScope.is_debug = true;

  var a = $scope.a;

  a.reloginData = function () {
    return {
      mylogin : a.session.si.user.login
    };
  };

  $scope.$parent.b_$DEV = {
    openPage : openPage,
    isForm : isForm,
    editForm : editForm,
    editLang : editLang,
    editHelp : editHelp,
    openWidgetPage : openWidgetPage,
    editWidgetForm : editWidgetForm,
    editWidgetLang : editWidgetLang,
    toggleTranslate : toggleTranslate
  };

  bHttp.loadUri = loadUri;

  bConfig.onLocationChange(function() {
    a.translating = false;
    $('b-page, b-page-toolbar').removeClass('translating');
  });

  window.BS = a;
  prepareProject();
  prepareMenu();

  function prepareProject() {
    var qPpp = $http.post('b/core/md/dev/get_projects').then(function(result) {
      return result.data;
    });
    var qPs  = $http.post('dev/projects').then(function(result) {
      return result.data;
    });
    $q.all([qPpp, qPs]).then(function(d){
      var usedCodes = d[1].trim().split(',');
      var availCodes = _.chain(d[0])
                        .filter(function(item) { return _.contains(usedCodes, item[0]);})
                        .each(function(item) { item[1] = String(item[1]).trim().split(',');})
                        .object()
                        .value();
      var p = {
        data  : d,
        codes : availCodes,
        codeOfUri : function(uri){
          var codes = this.codes;
          var str = String(uri).substring(1);
          var prefix = str.substring(0,str.indexOf('/'));
          var projectCode = '';
          _.each(codes, function(val, key) {
            if(_.contains(val, prefix)) {
              if(projectCode) throw 'Duplicate project code';
              projectCode = key;
            }
          });
          if(!projectCode) throw 'Project code not found';
          return projectCode;
        }
      }
      window.bProject = p;
    });
  }

  function prepareMenu() {
    $http.post('b/core/md/dev/get_menus').then(function(menu) {
      AppSession.sessionDone.then(function() {
        _.each(AppSession.si.projects, function(project) {
          _.each(project.filials, function(filial){
            var menu_forms = angular.copy(menu.data);
            _.each(menu_forms, function (m) {
              _.each(m.forms, function (f) {
                f.url = '#' + bConfig.pathPrefix(project.hash, filial.id) + f.uri;
              });
            });
            filial.menus.push({
              name : 'Developer',
              menus : menu_forms
            });
          });
        });
      });
    });
  }

  bAlert.open = function (error, title) {
    if(error && error.type === 'route404') {
      $http.get('b/core/md/dev/get_procedures?path=' + bHttp.extractPath(error.path || ''))
      .success(function (result) {
        bAlert.procedures = result.procedures;
      })
      .error(function (error) {
        bAlert.procedures = [];
        console.error(error);
      });
    }
    bAlert.openReal(error, title);
  };

  bAlert.addRoute = function addRoute() {
    var data = {
      uri : bAlert.uri,
      action_name : bAlert.procedure
    };
    $http.post('b/core/md/dev/save_route', data)
    .success(function () {
      bAlert.hide();

      var path = bHttp.extractPath(bAlert.uri);
      var project_code = bProject.codeOfUri(path);
      $http.post('b/core/md/dev/form&gen_form', {path:path})
      .then(function(result){
        $http.post('dev/' + project_code + '/save/oracle/uis/form' + path + '.sql', result.data)
        .then(function(){window.location.reload();});
      });
    })
    .error(function (error, status) {
      window.alert('Status:' + status + '\nError:' + JSON.stringify(error));
    });
  };

  bHttp.fetchLang = _.wrap(bHttp.fetchLang, function (func, path) {
    if (bConfig.langCode() !== 'dev' && !path.startsWith('/core/md/dev')) {
      return func(path);
    }
    return $q.when({});
  });

  function openPage() {
    var path = bHttp.extractPath(bFrame.parseUrl().path);
    return $http.get('dev/' + bProject.codeOfUri(path) + '/open/page/form' + path + '.html');
  }

  function loadLang() {
    if (path.startsWith('/core/md/dev') || bConfig.langCode.get() == 'dev') {
      return $q.when({});
    } else {
      return bHttp.fetchLang(path);
    }
  }

  function isForm() {
    var p = $location.path();
    return !(/\/core\/md\/dev\//.test(p));
  }

  function editForm() {
    bFrame.open('/core/md/dev/form', {
      form : bFrame.parseUrl().path
    });
  }

  function editLang() {
    bFrame.open('/core/md/dev/form_translate', {
      form : bFrame.parseUrl().path
    });
  }

  function editHelp() {
    var page = _.last(bFrame.pages);
    if (page) {
      var path  = "page/help/" + bConfig.langCode() + page.path;
      window.open('make_help.html?path=' + path + '&code=' + bProject.codeOfUri(page.path));
    }
  }

  function openWidgetPage(widget) {
    return $http.get('dev/' + bProject.codeOfUri(widget.path) + '/open/page/form' + widget.path + '.html');
  }

  function editWidgetForm(widget) {
    bFrame.open('/core/md/dev/form', {
      form : widget.path
    });
  }

  function editWidgetLang(widget) {
    bFrame.bWidget = widget;
    bFrame.open('/core/md/dev/form_translate', {
      form : widget.path,
      widget : true
    });
  }

  function loadUri(uri) {
    var options = {
      transformResponse : null
    };
    return $http.get(uri, options).then(function (response) {
      if (response.headers('BiruniStaticPage') === 'Yes') {
        return '<biruni-static-page/>' + response.data;
      }
      return response.data;
    }, function (response) {
      return $q.reject(response);
    });
  }

  function toggleTranslate() {
    a.translating = !a.translating;

    if (!a.translating) {
      saveTranslate();
    }
    var page = _.last(bFrame.pages);
    page.contentElem.toggleClass('translating');
    page.toolbarElem.toggleClass('translating');
  }

  function saveTranslate() {
    var page = _.last(bFrame.pages);
    var path = 'page/lang/' + bConfig.langCode() + bHttp.extractPath(page.path) + '.json';
    $http.post('dev/' + bProject.codeOfUri(page.path) + '/save/' + path, $filter('json')(_.pick(page.pureLangs, _.identity), 1))
  }

});
