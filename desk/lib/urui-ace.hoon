::  urui-ace: $ace-spec -> the Ace loader configuration script.
::
::  Served as an external script at the application's configuration URL.
::
/-  urui
|%
::
++  config-js
  ::  Emit the Ace basePath/modePath/themePath/workerPath script.
  ::
  |=  =ace-spec:urui
  ^-  @t
  =/  config=json
    %-  pairs:enjs:format
    :~  ['version' s+version.ace-spec]
        ['basePath' s+base.ace-spec]
        ['mode' s+mode.ace-spec]
        ['lightTheme' s+light.ace-spec]
        ['darkTheme' s+dark.ace-spec]
        ['extensions' a+(turn exts.ace-spec |=(ext=@t s+ext))]
        ['useWorker' b+use-worker.ace-spec]
    ==
  %+  rap  3
  :~  '''
      (function configureAce(global) {
        'use strict';
        if (!global.ace) {
          throw new Error('Could not load the Ace runtime');
        }
        const assets =
      '''
      (en:json:html config)
      '''
      ;
        for (const name of ['basePath', 'modePath',
                           'themePath', 'workerPath']) {
          global.ace.config.set(name, assets.basePath);
        }
        global.ace.config.set('loadWorkerFromBlob', false);
        Object.freeze(assets.extensions);
        global[
      '''
      (en:json:html s+global.ace-spec)
      '''
      ] = Object.freeze(assets);
      })(window);
      '''
  ==
--
