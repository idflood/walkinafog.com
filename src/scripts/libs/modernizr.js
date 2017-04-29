/* Modernizr 2.6.1 (Custom Build) | MIT & BSD
 * Build: http://modernizr.com/download/#-shiv-cssclasses
 */
;window.Modernizr=function(a,b,c){
 function u(a){j.cssText=a}function v(a,b){return u(prefixes.join(a+";")+(b||""))}function w(a,b){return typeof a===b}function x(a,b){return!!~(""+a).indexOf(b)}function y(a,b,d){for(var e in a){var f=b[a[e]];if(f!==c)return d===!1?a[e]:w(f,"function")?f.bind(d||b):f}return!1}
 var d="2.6.1";
 var e={};
 var f=!0;
 var g=b.documentElement;
 var h="modernizr";
 var i=b.createElement(h);
 var j=i.style;
 var k;
 var l={}.toString;
 var m={};
 var n={};
 var o={};
 var p=[];
 var q=p.slice;
 var r;
 var s={}.hasOwnProperty;
 var t;
 !w(s,"undefined")&&!w(s.call,"undefined")?t=(a, b) => s.call(a,b):t=(a, b) => b in a&&w(a.constructor.prototype[b],"undefined"),Function.prototype.bind||(Function.prototype.bind=function(b){
  var c=this;if(typeof c!="function")throw new TypeError;
  var d=q.call(arguments,1);
  var e=function(...args) {if(this instanceof e){var a=() => {};a.prototype=c.prototype;var f=new a,g=c.apply(f,d.concat(q.call(args)));return Object(g)===g?g:f}return c.apply(b,d.concat(q.call(args)));};
  return e
 });for(var z in m)t(m,z)&&(r=z.toLowerCase(),e[r]=m[z](),p.push((e[r]?"":"no-")+r));return e.addTest=(a, b) => {if(typeof a=="object")for(var d in a)t(a,d)&&e.addTest(d,a[d]);else{a=a.toLowerCase();if(e[a]!==c)return e;b=typeof b=="function"?b():b,f&&(g.className+=" "+(b?"":"no-")+a),e[a]=b}return e},u(""),i=k=null,((a, b) => {
  function k(a,b){
   var c=a.createElement("p");
   var d=a.getElementsByTagName("head")[0]||a.documentElement;
   return c.innerHTML="x<style>"+b+"</style>",d.insertBefore(c.lastChild,d.firstChild)
  }function l(){var a=r.elements;return typeof a=="string"?a.split(" "):a}function m(a){var b=i[a[g]];return b||(b={},h++,a[g]=h,i[h]=b),b}function n(a,c,f){c||(c=b);if(j)return c.createElement(a);f||(f=m(c));var g;return f.cache[a]?g=f.cache[a].cloneNode():e.test(a)?g=(f.cache[a]=f.createElem(a)).cloneNode():g=f.createElem(a),g.canHaveChildren&&!d.test(a)?f.frag.appendChild(g):g}function o(a,c){
   a||(a=b);if(j)return a.createDocumentFragment();c=c||m(a);
   var d=c.frag.cloneNode();
   var e=0;
   var f=l();
   var g=f.length;
   for(;e<g;e++)d.createElement(f[e]);return d
  }function p(a,b){b.cache||(b.cache={},b.createElem=a.createElement,b.createFrag=a.createDocumentFragment,b.frag=b.createFrag()),a.createElement=c => r.shivMethods?n(c,a,b):b.createElem(c),a.createDocumentFragment=Function("h,f","return function(){var n=f.cloneNode(),c=n.createElement;h.shivMethods&&("+l().join().replace(/\w+/g,a => (b.createElem(a), b.frag.createElement(a), 'c("'+a+'")'))+");return n}")(r,b.frag)}function q(a){a||(a=b);var c=m(a);return r.shivCSS&&!f&&!c.hasCSS&&(c.hasCSS=!!k(a,"article,aside,figcaption,figure,footer,header,hgroup,nav,section{display:block}mark{background:#FF0;color:#000}")),j||p(a,c),a}
  var c=a.html5||{};
  var d=/^<|^(?:button|map|select|textarea|object|iframe|option|optgroup)$/i;
  var e=/^<|^(?:a|b|button|code|div|fieldset|form|h1|h2|h3|h4|h5|h6|i|iframe|img|input|label|li|link|ol|option|p|param|q|script|select|span|strong|style|table|tbody|td|textarea|tfoot|th|thead|tr|ul)$/i;
  var f;
  var g="_html5shiv";
  var h=0;
  var i={};
  var j;
  ((() => {try{var a=b.createElement("a");a.innerHTML="<xyz></xyz>",f="hidden"in a,j=a.childNodes.length==1||(() => {b.createElement("a");var a=b.createDocumentFragment();return typeof a.cloneNode=="undefined"||typeof a.createDocumentFragment=="undefined"||typeof a.createElement=="undefined"})()}catch(c){f=!0,j=!0}}))();var r={elements:c.elements||"abbr article aside audio bdi canvas data datalist details figcaption figure footer header hgroup mark meter nav output progress section summary time video",shivCSS:c.shivCSS!==!1,supportsUnknownElements:j,shivMethods:c.shivMethods!==!1,type:"default",shivDocument:q,createElement:n,createDocumentFragment:o};a.html5=r,q(b)
 })(this,b),e._version=d,g.className=g.className.replace(/(^|\s)no-js(\s|$)/,"$1$2")+(f?" js "+p.join(" "):""),e;
}(this,this.document);