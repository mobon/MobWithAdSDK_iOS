 (function() {
     const placementId = '__PLACEMENT_ID__';
     const customBridgeName = '__BRIDGE_NAME__';
     const html = '__HTML__';
     
     const container = document.querySelector('.mobwith-banner[data-placement-id="' + placementId + '"]');
          
     if (!container) {
         return;
     }

     if (typeof container.__mobwithCleanup === 'function') {
         container.__mobwithCleanup();
     }
     
     container.innerHTML = '';
     const iframe = document.createElement('iframe');

     iframe.style.width = '100%';
     iframe.style.height = '0px';
     iframe.style.border = '0';
     iframe.style.display = 'block';
     iframe.style.overflow = 'hidden';
     iframe.setAttribute(
         'scrolling',
         'no'
     );

     container.appendChild(
         iframe
     );

     const doc =
         iframe.contentDocument ||
         iframe.contentWindow?.document;

     if (!doc) {
         return;
     }

     let destroyed = false;
     let resizePending = false;
     let timer = null;
     let mutationObserver = null;
     let resizeObserver = null;
     const imageListeners = [];
     
     let lastScale = 0;
     let lastIframeHeight = 0;
     
     
     const resizeIframe = function() {
         if (destroyed) {
             return;
         }

         try {
             const body = iframe.contentWindow?.document?.body;
             const html = iframe.contentWindow?.document?.documentElement;

             if (!body || !html) {
                 return;
             }
             
             console.log('[MobWith]', {
                         bodyScroll: body.scrollHeight,
                         bodyOffset: body.offsetHeight,
                         bodyClient: body.clientHeight,
                         htmlScroll: html.scrollHeight,
                         htmlOffset: html.offsetHeight,
                         htmlClient: html.clientHeight,
                         bodyMargin: getComputedStyle(body).margin,
                         htmlMargin: getComputedStyle(html).margin
                     });
             
             
             console.log({
                 htmlHeight: getComputedStyle(html).height,
                 htmlMinHeight: getComputedStyle(html).minHeight,
                 bodyHeight: getComputedStyle(body).height,
                 bodyMinHeight: getComputedStyle(body).minHeight

             });

             console.log({
                 bodyRect: body.getBoundingClientRect().height,
                 htmlRect: html.getBoundingClientRect().height
             });
             
             console.log({
                 innerHeight: iframe.contentWindow.innerHeight,
                 visualViewport: iframe.contentWindow.visualViewport?.height,
                 documentClient: iframe.contentWindow.document.documentElement.clientHeight
             });
             
             console.log(doc.compatMode);
             
             const contentWidth = Math.max(
                 body.scrollWidth,
                 html.scrollWidth
             );
             
             const contentHeight = Math.max(
                 body.scrollHeight,
                 body.offsetHeight,
                 body.clientHeight,
                 html.scrollHeight,
                 html.offsetHeight,
                 html.clientHeight
             );

             let containerWidth = container.getBoundingClientRect().width;
             if (containerWidth <= 0) {
                 containerWidth = window.innerWidth;
             }

             let scale = 1;
             if (contentWidth > 0 && containerWidth > contentWidth) {
                 scale = containerWidth / contentWidth;
             }
             
             const iframeHeight = contentHeight * scale;
             if (lastScale !== scale || lastIframeHeight !== iframeHeight) {
                 lastScale = scale;
                 lastIframeHeight = iframeHeight;
                 
                 body.style.transformOrigin = '0 0';
                 body.style.transform = `scale(${scale})`;
                 iframe.style.height = iframeHeight + 'px';
             }
             
             console.log({
                 bodyScrollWidths: body.scrollWidth,
                 htmlScrollWidths: html.scrollWidth,
                 containerWidths: containerWidth,
                 scales: scale,
                 iframeHeights: iframeHeight
             });
             
         } catch (e) {
             console.log(e);
         }
     };

     const requestResize = function() {
         if (destroyed || resizePending) {
             return;
         }

         resizePending = true;

         requestAnimationFrame(function() {
             resizePending = false;
             resizeIframe();
         });
     };

     const cleanup = function() {
         if (destroyed) {
             return;
         }

         destroyed = true;

         if (timer) {
             clearInterval(timer);
             timer = null;
         }

         mutationObserver?.disconnect();
         resizeObserver?.disconnect();

         imageListeners.forEach(function(item) {
             item.image.removeEventListener('load', item.handler);
             item.image.removeEventListener('error', item.handler);
         });

         imageListeners.length = 0;

         if (container.__mobwithCleanup === cleanup) {
             delete container.__mobwithCleanup;
         }
     };

     container.__mobwithCleanup = cleanup;

     iframe.onload =
         function() {

         requestResize();

         const body =
             iframe.contentWindow
             .document.body;

         if (!body) {
             return;
         }

         mutationObserver =
             new MutationObserver(
                 function() {
                     requestResize();
                 }
             );

         mutationObserver.observe(
             body,
             {
                 childList: true,
                 subtree: true,
                 attributes: true,
                 characterData: true
             }
         );

         if (
             window.ResizeObserver
         ) {

             resizeObserver =
                 new ResizeObserver(
                     function() {
                         requestResize();
                     }
                 );

             resizeObserver.observe(
                 body
             );
         }

         const images =
             iframe.contentWindow
             .document.images;

         for (
             let i = 0;
             i < images.length;
             i++
         ) {
             const handler = requestResize;

             images[i].addEventListener('load', handler);
             images[i].addEventListener('error', handler);

             imageListeners.push({
                 image: images[i],
                 handler: handler
             });
         }

        let count = 0;
         timer =
             setInterval(
                 function() {

                     requestResize();

                     count++;

                     if (
                         count >= 40
                     ) {
                         clearInterval(
                             timer
                         );
                     }

                 },
                 250
             );
     };

     doc.open();
     doc.write(html);
     doc.close();

     let initBridgeRetryCount = 0;
     const maxInitBridgeRetryCount = 100;

     function initBridge() {
         if (destroyed || !iframe.isConnected) {
             return;
         }
         const mob = iframe.contentWindow?.MobwithAD;
         if (mob && typeof mob.init === 'function') {
             mob.init({
                 bridgeName: customBridgeName
             });
             requestResize();
             return ;
         }

         initBridgeRetryCount++;

         if (initBridgeRetryCount >= maxInitBridgeRetryCount) {
             console.warn('MobwithAD.init retry exceeded');
             return;
         }

         setTimeout(initBridge, 50);
     }

     initBridge();

     requestResize();

 })();
