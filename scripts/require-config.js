require.config({
  paths: {
    Underscore: 'libs/underscore',
    text: "libs/require/text",
    "socket.io": "libs/socket.io/socket.io",
    cs: "libs/require/cs",
    Three: "libs/three.js/build/Three",
    EffectComposer: 'libs/three.js/examples/js/postprocessing/EffectComposer',
    RenderPass: 'libs/three.js/examples/js/postprocessing/RenderPass',
    BloomPass: 'libs/three.js/examples/js/postprocessing/BloomPass',
    FilmPass: 'libs/three.js/examples/js/postprocessing/FilmPass',
    TexturePass: 'libs/three.js/examples/js/postprocessing/TexturePass',
    ShaderPass: 'libs/three.js/examples/js/postprocessing/ShaderPass',
    MaskPass: 'libs/three.js/examples/js/postprocessing/MaskPass',
    ShaderExtras: 'libs/three.js/examples/js/ShaderExtras'
  },
  shim: {
    'Underscore': {
      exports: "_"
    },
    'Three': {
      exports: "THREE"
    },
    'EffectComposer': ['Three'],
    'RenderPass': ['Three'],
    'BloomPass': ['Three'],
    'FilmPass': ['Three'],
    'TexturePass': ['Three'],
    'ShaderPass': ['Three'],
    'MaskPass': ['Three'],
    'ShaderExtras': ['Three']
  }
});
