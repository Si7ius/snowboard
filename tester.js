biruni.directive('bGrid', function ($parse, $compile, bAlert, bStorage) {
  var pageHeader = $('body').find('.page-header').first(),
      isSticky = false;

  function parse(attr) {
    if (attr) {
      return $parse(attr);
    }
  }

  function gridHeaderPinning(elem, path) {
    var pinKey = path + '~sticky';

    if (!isSticky) {
      bStorage.json(pinKey, {});
      return;
    }

    var $gridHead = elem.find('.b-grid-header');
        $edgeBtn = elem.find('.edge-btn'),
        $edgeIcn = $edgeBtn.find('i');

    $edgeBtn.removeClass('d-none');

    function isPinEnabled(){
      var pinVal = bStorage.json(pinKey) || {};
      return pinVal.isPinned == 'Y';
    };

    function togglePin(enable){
      $gridHead.toggleClass('sticky-header');
      $edgeBtn.toggleClass('btn-warning');
      $edgeIcn.css('transform', enable ? 'rotate(0)' : 'rotate(45deg)');
      bStorage.json(pinKey, { isPinned: enable ? 'Y' : 'N' });
    };

    function clickPin() {
      togglePin(!isPinEnabled());
    };

    if (isPinEnabled()) togglePin(true);
    $edgeBtn.click(clickPin);
  }

  function render(elem, html, v, query, grid) {
    if (v) {
      elem.html(html());
      elem.show();
      elem.find('.sg-header [sort-header]').click(function () {
        var name = $(this).attr('sort-header'),
        sortCol = _.first(query.sort()),
        sortDir = _.first(sortCol);
        if (sortDir === '-') {
          sortCol = sortCol.substr(1);
        }
        if (sortCol === name) {
          if (sortDir === '-') {
            query.sort([]);
          } else {
            query.sort(['-' + name]);
          }
        } else {
          query.sort([name]);
        }
        query.fetch();
      });
      gridHeaderPinning(elem, grid.query().path());
    }
  }

  function showAction($t, grid, scope, event) {
    var acn = '.sg-sub-row.sg-action';
    var $elem = $t.find('sliding');
    var $a = $elem.find(acn);
    if ($a.length == 0) {
      $elem.append(grid.g.actionHtml);
      $a = $elem.find(acn);
      var s = scope.$new(false);
      s.row = grid.rowAt($t.index());
      $compile($a.contents())(s);
    }
    $a.show();
  }

  function showRows($t, grid, scope, event) {
    var acn = 'sliding';
    var $elem = $t.find('sliding');
    var $rests;
    if($(event.target).closest('.sg-action').length == 0) {
      if($elem.hasClass('opened-slider')) {
        $elem.removeClass('opened-slider');
        $elem.addClass('closed-slider');
        $elem.slideUp(100);
        $t.css('box-shadow', 'none');
      } else {
        $rests = $t.parent().find('sliding.opened-slider');
        $rests.removeClass('opened-slider');
        $rests.addClass('closed-slider');
        $rests.slideUp(100);
        $rests.parent().css('box-shadow', 'none');

        $elem.removeClass('closed-slider');
        $elem.addClass('opened-slider');
        $elem.slideDown(200);
        $t.css('box-shadow', 'inset 0 0 1px #aab');
      }
      $elem.css({display:'block'});
    }
  }

  function onRowClick(scope, grid, event) {
    event.preventDefault();
    if (grid.g.actionHtml) {
      scope.$apply(_.partial(showAction, $(this), grid, scope, event));
    }
    scope.$apply(_.partial(showRows,  $(this), grid, scope, event));
  }

  function onRowDoubleClick(scope, gridRowAt, doubleClick, event) {
    event.preventDefault();
    if (_.isFunction(doubleClick)) {
      var val = {
        row : gridRowAt($(this).index())
      };
      scope.$apply(_.partial(doubleClick, scope, val));
    }
  }

  function onCellClick(scope, grid, event) {
    event.preventDefault();
    event.stopPropagation();
    var cb = grid.g.fields[$(this).attr('cn')];
    if (cb && cb.onClick) {
      if (_.isString(cb.onClick)) {
        cb = parse(cb.onClick);
      }
      var val = {
        row : grid.rowAt($(this).closest('.sg-row').index())
      };
      scope.$apply(_.partial(cb, scope, val));
    }
  }

  function composeOnCheck(scope, onCheck, checkedApi, indices) {
    if (onCheck) {
      onCheck(scope, {
        checked : checkedApi(indices)
      });
    }
  }

  function whenCheck(elem, scope, onCheck, event) {
    event.stopPropagation();
    var checkAll = elem.find('input[bcheckall]');
    var checkboxes = elem.find('input[data-bcheck]');
    var indices = _.chain(checkboxes)
      .filter(function (x) {
        return x.checked;
      })
      .map(function (x) {
        return parseInt(x.dataset.bcheck);
      })
      .value();

    checkAll.prop('indeterminate', indices.length > 0 && indices.length != checkboxes.length);
    checkAll.prop('checked', checkboxes.length > 0 && indices.length == checkboxes.length);

    scope.$apply(_.partial(onCheck, indices));
  }

  function whenCheckAll(elem, scope, onCheck, event) {
    var ch = this.checked;
    elem.find('input[data-bcheck]').each(function () {
      this.checked = ch;
    });
    whenCheck(elem, scope, onCheck, event);
  }

  function splitNames(xs) {
    if (xs) {
      return _.chain(xs.split(','))
      .invoke('trim')
      .compact()
      .value();
    }
    return [];
  }

  function setFieldFlags(grid, fieldNames, flagNames) {
    _.each(fieldNames, function (fn) {
      var f = grid.getField(fn);
      _.each(flagNames, function (n) {
        f[n] = true;
      });
    });
  }

  function translateFields(g, translate) {
    var prefix = g.translateKey;
    if (_.isUndefined(prefix)) {
      prefix = g.name + '.';
    }
    _.each(g.fields, function (f) {
      if (f.column || f.searchable) {
        f.label = translate(prefix + f.name);
      } else if (f.filter) {
        f.label = translate(prefix + (f.decorateWith || f.name));
      }
    });
  }

  function evalSavedData(grid) {
    var path = grid.query().path(),
    s = bStorage.json(path);

    grid.g.rowsDefault = angular.copy(grid.g.rows);

    if (!(grid.g.withCheckbox && s.mc == 24) && s.rows && _.chain(s.rows)
      .flatten()
      .pluck('name')
      .compact()
      .every(function (n) {
        var f = grid.g.fields[n];
        return f && f.column;
      })
      .value()) {
      grid.g.rows = s.rows;
    }

    if (s.search && _.every(s.search, function (n) {
        var f = grid.g.fields[n];
        return f && f.searchable;
      })) {
      _.each(grid.g.fields, function(field) {
        field.search = _.contains(s.search, field.name);
      });
      grid.query().searchFields(s.search);
    }
  }

  function ctrl($scope, $attrs) {
    var grid = $scope.bPage.grid($attrs.name);

    function setFlags(names, flagNames) {
      setFieldFlags(grid, splitNames(names), flagNames);
    }

    setFlags($attrs.required, ['required']);
    setFlags($attrs.search, ['search', 'searchable']);
    setFlags($attrs.searchable, ['searchable']);
    setFlags($attrs.extraColumns, ['column']);

    var searchNames =
      _.chain(grid.g.fields)
      .where({
        search : true
      })
      .pluck('name')
      .value();

    var sortFields = splitNames($attrs.sort);

    grid.query().searchFields(searchNames);

    if (sortFields.length) grid.query().sort(sortFields);

    grid.g.name = $attrs.name;
    grid.g.translateKey = $attrs.translateKey;
    this.grid = grid;
  }

  function link(scope, elem, attr, ctrl) {
    var grid = ctrl.grid,
    query = grid.query(),
    onDblclick = parse(attr.onDblclick),
    onCheck = _.partial(composeOnCheck, scope, parse(attr.onCheck), grid.checkedApi, _),
    htmlTable = _.partial(grid.htmlTable, !!attr.onCheck);
    isSticky = !!attr.$attr.sticky;

    translateFields(grid.g, scope.bPage.translate);

    if(attr.onCheck) grid.g.withCheckbox = true;
    evalSavedData(grid);

    scope.$watch(query.fetching, _.partial(render, elem, htmlTable, _, query, grid));
    if (grid.g.enabled) {
      grid.fetch().then(null, function(result) {
        bAlert.open(result);
      });
    }

    elem.on('click', '.sg > .sg-content > .sg-row', _.partial(onRowClick, scope, grid, _));
    elem.on('click', '.sg a.b-grid-cell', _.partial(onCellClick, scope, grid, _));
    elem.on('dblclick', '.sg > .sg-content > .sg-row', _.partial(onRowDoubleClick, scope, grid.rowAt, onDblclick, _));

    elem.on('click', 'input[bcheckall]', _.partial(whenCheckAll, elem, scope, onCheck, _));
    elem.on('click', '.sg > .sg-content .checkbox', _.partial(whenCheck, elem, scope, onCheck, _));
    elem.on('dblclick', '.sg > .sg-content .checkbox', function (e) {
      e.stopPropagation();
    });
    scope.bPage.qLoaded.promise.then(_.partial(onCheck, []));
  }

  return {
    restrict : 'E',
    scope : true,
    controller : ctrl,
    link : link
  };

});
