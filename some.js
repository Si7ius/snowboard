biruni.directive('t', function ($templateCache, $rootScope, $compile) {

  function compile(elem, attr) {
    var txt = elem.text();

    function translate(scope) {
      var r = scope.bWidget? scope.bWidget : scope.bPage;
      return r.translate;
    }

    function preLink(scope, elem, attr) {
      if ($rootScope.is_debug && !scope.bWidget && false) {
        var tdev = $("<tdev>").append($templateCache.get('b-mini-translate.html')).attr("key", txt);
        elem.after(tdev);
        $compile(tdev)(scope);
      }
      translate(scope)(txt, []);
    }

    function postLink(scope, elem, attr) {
      var ps = [];
      for (var i = 0; i < 10; i++) {
        var p = attr['p' + (i + 1)];
        if (p) {
          ps.push('');
          watch(p, i);
        } else {
          break;
        }
      }

      function watch(p, i) {
        scope.$watch(p, function (v) {
          ps[i] = v;
          update();
        });
      }

      function update() {
        elem.text(translate(scope)(txt, ps));
      }
      update();

      if ($rootScope.is_debug && !scope.bWidget) scope.updateTranslate = update;
    }

    return {
      pre  : preLink,
      post : postLink
    }
  }

  return {
    restrict : 'E',
    scope: true,
    compile : compile
  };
});
