// ==VimperatorPlugin==
// @name           Command-MainMenu
// @description-ja メインメニューをコマンドで実行できる
// @version        0.1
// ==/VimperatorPlugin==
//
// Usage:
//    :menu ツール-アドオン
//    のようにメニューの"-"区切りのパスを渡すことで、メニューをクリックします。
//    Migemo必須。
//
// TODO:
//    一度開かないと生成されないようなメニュー(ラベル)に対処できる魔法があったらいいな！
//    (ScrapBook / ブックマークメニュー)

(function(){ 

  var migemo = Components
        .classes['@piro.sakura.ne.jp/xmigemo/factory;1']
        .getService(Components.interfaces.pIXMigemoFactory)
        .getService("ja");

  function isMenu (elem) {
    return elem.nodeName.match(/^menu(item)?$/i);
  }

  function cloneArray (src) {
    return src.map(function(it){return it;});
  }

  function menuPath (menu, root) {
    var res = [];
    while (menu != root) {
      isMenu(menu) && res.unshift(menu.label);
      menu = menu.parentNode;
    }
    return res.join('-');
  }

  function findMenu (elem, names, single) {
    if (isMenu(elem)) {
      if (names[0](elem.label)) {
        if (names.length == 1)
          return single ? elem : [elem];
        (names = cloneArray(names)).shift();
      } else {
        return single ? null : [];
      }
    }

    var menu, cs = elem.childNodes, result = [];
    for (var i = 0; i < cs.length; i++) {
      if (menu = findMenu(cs[i], names, single)) {
        if (single) {
          return menu; 
        } else {
          menu.map(function(it){ result.push(it); });
        }
      }
    }
    if (!single)
      return result;
  }

  function getPathMatchers (args) {
    return args.split('-').map(function(it){
      let n = it.toLowerCase();
      let re = new RegExp(migemo.getRegExp(it.replace(/^\s+|\s+$/, '')));
      return function (l) {
        return (l.toLowerCase().indexOf(n) >= 0) || re.test(l);
      }
    });
  }

  function findMenuByArgs(args, single) {
    const root = document.getElementById('main-menubar');
    return findMenu(root, getPathMatchers(args), single);
  }

  liberator.commands.addUserCommand(
    ['menu'],
    'Command MainMenu',
    function (args, _, num, extra) {
      var res = findMenuByArgs(args.replace(/-\s*$/,''), true);
      if (res && res.click) {
        res.click();
      } else {
        liberator.echoerr('menu not found');
      }
    },
    {
      completer: function(filter) {
        var cs = findMenuByArgs(filter, false).map(function(it){return [menuPath(it), ''];});
        return [0, cs];
      }
    }
  );


})();


