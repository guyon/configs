// Vimperator plugin: 'Walk Input'
// License: BSD
// Version: 1.3.0
// Maintainer: Takayama Fumihiko <tekezo@pqrs.org>
//             anekos <anekos@snca.net>

// ------------------------------------------------------------
// The focus walks <input> & <textarea> elements.
// If you type M-i first, the focus moves to "<input name='search' />".
// Then if you type M-i once more, the focus moves to "<input name='name' />".
//
// <html>
//     <input name="search" />
//     <a href="xxx">xxx</a>
//     <a href="yyy">yyy</a>
//     <a href="zzz">zzz</a>
//     <input name="name" />
//     <textarea name="comment"></textarea>
// </html>

//***************************************
// E4X is now disabled in Firefox 20.
// We cannot write raw XML code in javascript file.
// For detail, see https://developer.mozilla.org/en/docs/E4X .
//***************************************
// PLUGIN_INFO {{{
let INFO =
{"plugin":{"author":"Takayama Fumihiko","author":"anekos","license":"BSD","project":null,"p":[null,null],"code":"\n<html>\n  <input name=\"search\" />\n  <a href=\"xxx\">xxx</a>\n  <a href=\"yyy\">yyy</a>\n  <a href=\"zzz\">zzz</a>\n  <input name=\"name\" />\n  <textarea name=\"comment\"></textarea>\n</html>\n\t","item":{"tags":"i_<M-i> i_<A-i> <M-i> <A-i>","spec":"<M-i>","spec":"<A-i>","description":{"p":"Move focus forward"}},"item":{"tags":"i_<M-S-i> i_<A-S-i> <M-S-i> <A-S-i>","spec":"<M-S-i>","spec":"<A-S-i>","description":{"p":"Move focus backward"}}}};
// }}}
// converted by xml2json-xslt ( http://code.google.com/p/xml2json-xslt/ )

(function () {

var types = [
  "text",
  "password",
  "search",
  "datetime",
  "datetime-local",
  "date",
  "month",
  "time",
  "week",
  "number",
  "range",
  "email",
  "url",
  "tel",
  "color",
].map(function(type) "@type=" + type.quote()).join(" or ");
var xpath = '//input[(' + types + ' or not(@type)) and not(@disabled)] | //textarea';

function isVisible (elem) {
  while (elem && !(elem instanceof HTMLDocument)) {
    if (/^none$/i.test(getComputedStyle(elem, '').display))
      return false;
    elem  = elem.parentNode;
  }
  return true;
}

var walkinput = function (forward) {
    var focused = document.commandDispatcher.focusedElement;
    var current = null;
    var next = null;
    var prev = null;
    var list = [];

    (function (frame) {
      var doc = frame.document;
      if (doc.body.localName.toLowerCase() == 'body') {
        let r = doc.evaluate(xpath, doc, null, XPathResult.ORDERED_NODE_SNAPSHOT_TYPE, null);
        for (let i = 0, l = r.snapshotLength; i < l; ++i) {
            let e = r.snapshotItem(i);
            if (!isVisible(e))
              continue;
            let ef = {element: e, frame: frame};
            list.push(ef);
            if (e == focused) {
                current = ef;
            } else if (current && !next) {
                next = ef;
            } else if (!current) {
                prev = ef;
            }
        }
      }
      for (let i = 0; i < frame.frames.length; i++)
        arguments.callee(frame.frames[i]);
    })(content);

    if (list.length <= 0)
      return;

    var elem = forward ? (next || list[0])
                       : (prev || list[list.length - 1]);

    if (!current || current.frame != elem.frame)
      elem.frame.focus();
    elem.element.focus();
};

let mapForward = liberator.globalVariables.walk_input_map_forward || '<M-i> <A-i>'
let mapBackward = liberator.globalVariables.walk_input_map_backward || '<M-S-i> <A-S-i>'

mappings.addUserMap([modes.NORMAL, modes.INSERT], mapForward.split(/\s+/),
                    'Walk Input Fields (Forward)', function () walkinput(true));
mappings.addUserMap([modes.NORMAL, modes.INSERT], mapBackward.split(/\s+/),
                    'Walk Input Fields (Backward)', function () walkinput(false));

})();

