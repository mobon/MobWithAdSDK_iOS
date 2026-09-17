 (function() {
     const placementId = '__PLACEMENT_ID__';
     const customBridgeName = '__BRIDGE_NAME__';
     const html = '__HTML__';
     const os = '__OS__';
     
     const selector =
         os === 'iOS'
             ? `.mobwith-banner[data-placement-id-ios="${placementId}"]`
             : `.mobwith-banner[data-placement-id-android="${placementId}"]`;

     const container = document.querySelector(selector);
     
     if (!container) {
         return;
     }
     
     // ✅ Container를 flex로 설정해서 iframe 중앙 정렬
     container.style.display = 'flex';
     container.style.justifyContent = 'center';
     container.style.alignItems = 'flex-start';

     if (typeof container.__mobwithCleanup === 'function') {
         container.__mobwithCleanup();
     }
     
     container.innerHTML = '';
     const iframe = document.createElement('iframe');

     iframe.style.height = '0px';
     iframe.style.border = '0';
     iframe.style.display = 'block';
     iframe.style.overflow = 'hidden';
     iframe.style.background = 'transparent';
     iframe.setAttribute(
         'scrolling',
         'no'
     );
     
     // ✅ viewport 기반 가로 사이즈 제어
     const applyResponsiveWidth = function() {
         const viewportWidth = window.innerWidth;
         
         if (viewportWidth < 500) {
             iframe.style.width = '100%';
             iframe.style.marginLeft = 'auto';
             iframe.style.marginRight = 'auto';
         } else {
             iframe.style.width = '350px';
             iframe.style.marginLeft = 'auto';
             iframe.style.marginRight = 'auto';
         }
     };
     
     applyResponsiveWidth();

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
     let containerObserver = null;
     let viewportResizeHandler = null;
     const imageListeners = [];

     // Define lastMeasuredHeight and stableCount for ResizeObserver logic
     let lastMeasuredHeight = null;
     let stableCount = 0;
     let lastViewportWidth = window.innerWidth;
     let observersActive = true;  // ✅ observer 활성 상태 추적
     
     // ✅ 네이티브에서 강제 종료 플래그 설정 가능
     container.__mobwithDestroyed = false;

     const resizeIframe = function() {
         if (destroyed || container.__mobwithDestroyed) {
             console.log('[MobWith] resizeIframe skipped (destroyed)');
             return;
         }

         try {
             const body = iframe.contentWindow?.document?.body;
             const html = iframe.contentWindow?.document?.documentElement;

             if (!body || !html) {
                 return;
             }

             const height = Math.max(
                 body.scrollHeight,
                 body.offsetHeight,
                 body.clientHeight,
                 html.scrollHeight,
                 html.offsetHeight,
                 html.clientHeight
             );

             if (height > 0) {
                 // ✅ 현재 높이와 같으면 스킵 (불필요한 DOM 변경 방지)
                 const currentHeight = parseInt(iframe.style.height) || 0;
                 if (currentHeight === height) {
                     return;
                 }
                 
                 // Track height stability
                 if (lastMeasuredHeight === height) {
                     stableCount++;
                 } else {
                     stableCount = 0;
                     lastMeasuredHeight = height;
                 }

                 // ✅ 안정화되면 observer 비활성화 (기존 방식)
                 if (stableCount >= 10 && observersActive) {
                     console.log('[MobWith] Height stabilized at:', height + 'px - deactivating observers');
                     deactivateObservers();
                 }

                 iframe.style.height = height + 'px';
             }
         } catch (e) {
             console.log('[MobWith] resizeIframe error:', e);
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

         console.log('[MobWith] Cleanup called for placement:', placementId);
         
         // ✅ 1. 먼저 플래그 설정 (모든 콜백에서 즉시 return하도록)
         destroyed = true;
         container.__mobwithDestroyed = true;

         // ✅ 2. 즉시 observer disconnect (지연 없이)
         if (timer) {
             console.log('[MobWith] Clearing timer');
             clearInterval(timer);
             timer = null;
         }

         if (mutationObserver) {
             console.log('[MobWith] Disconnecting MutationObserver');
             try {
                 mutationObserver.disconnect();
             } catch (e) {
                 console.log('[MobWith] MutationObserver disconnect error:', e);
             }
             mutationObserver = null;
         }

         if (resizeObserver) {
             console.log('[MobWith] Disconnecting ResizeObserver');
             try {
                 resizeObserver.disconnect();
             } catch (e) {
                 console.log('[MobWith] ResizeObserver disconnect error:', e);
             }
             resizeObserver = null;
         }

         if (containerObserver) {
             console.log('[MobWith] Disconnecting ContainerObserver');
             try {
                 containerObserver.disconnect();
             } catch (e) {
                 console.log('[MobWith] ContainerObserver disconnect error:', e);
             }
             containerObserver = null;
         }
         
         // ✅ viewport resize 리스너 제거
         if (viewportResizeHandler) {
             console.log('[MobWith] Removing viewport resize handler');
             window.removeEventListener('resize', viewportResizeHandler);
             viewportResizeHandler = null;
         }

         imageListeners.forEach(function(item) {
             item.image.removeEventListener('load', item.handler);
             item.image.removeEventListener('error', item.handler);
         });

         imageListeners.length = 0;

         if (container.__mobwithCleanup === cleanup) {
             delete container.__mobwithCleanup;
         }
         
         if (container.__mobwithDestroyed !== undefined) {
             delete container.__mobwithDestroyed;
         }
         
         console.log('[MobWith] Cleanup completed');
     };

     container.__mobwithCleanup = cleanup;
     
     // ✅ Observer 비활성화 함수 (높이 안정화 시)
     const deactivateObservers = function() {
         if (!observersActive) return;
         
         console.log('[MobWith] Deactivating observers (height stabilized)');
         observersActive = false;
         
         if (mutationObserver) {
             try {
                 mutationObserver.disconnect();
             } catch (e) {
                 console.log('[MobWith] MutationObserver disconnect error:', e);
             }
         }
         
         if (resizeObserver) {
             try {
                 resizeObserver.disconnect();
             } catch (e) {
                 console.log('[MobWith] ResizeObserver disconnect error:', e);
             }
         }
         
         if (timer) {
             clearInterval(timer);
             timer = null;
         }
     };
     
     // ✅ Observer 재활성화 함수 (viewport 변경 시)
     const reactivateObservers = function() {
         if (observersActive || destroyed || container.__mobwithDestroyed) return;
         
         console.log('[MobWith] Reactivating observers (viewport changed)');
         observersActive = true;
         stableCount = 0;
         lastMeasuredHeight = null;
         
         const body = iframe.contentWindow?.document?.body;
         if (!body) return;
         
         // MutationObserver 재시작
         if (!mutationObserver) {
             mutationObserver = new MutationObserver(function() {
                 if (destroyed || container.__mobwithDestroyed) {
                     console.log('[MobWith] MutationObserver callback skipped (destroyed)');
                     return;
                 }
                 if (!observersActive) return;
                 requestResize();
             });
             
             mutationObserver.observe(body, {
                 childList: true,
                 subtree: true,
                 attributes: true,
                 characterData: true
             });
         }
         
         // ResizeObserver 재시작
         if (window.ResizeObserver && !resizeObserver) {
             resizeObserver = new ResizeObserver(function() {
                 if (destroyed || container.__mobwithDestroyed) {
                     console.log('[MobWith] ResizeObserver callback skipped (destroyed)');
                     return;
                 }
                 if (!observersActive) return;
                 requestResize();
             });
             
             resizeObserver.observe(body);
         }
     };

     iframe.onload = function() {
         try {
             // ✅ 이게 iframe 내부 문서의 body입니다
             const iframeBody = iframe.contentWindow?.document?.body;
             const iframeHtml = iframe.contentWindow?.document?.documentElement;
             
             if (iframeBody) {
                 // ✅ iframe 내부 문서의 <body> 태그에 스타일 적용
                 iframeBody.style.background = 'transparent';
             }
             
             if (iframeHtml) {
                 // ✅ iframe 내부 문서의 <html> 태그에 스타일 적용
                 iframeHtml.style.background = 'transparent';
             }
         } catch (e) {
             console.log('[MobWith] Failed to apply iframe body styles:', e);
         }
         
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
                     if (destroyed || container.__mobwithDestroyed) {
                         console.log('[MobWith] MutationObserver callback skipped (destroyed)');
                         return;
                     }
                     if (!observersActive) return;  // ✅ 비활성화되면 스킵
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
                         if (destroyed || container.__mobwithDestroyed) {
                             console.log('[MobWith] ResizeObserver callback skipped (destroyed)');
                             return;
                         }
                         if (!observersActive) return;  // ✅ 비활성화되면 스킵
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
                     if (destroyed || container.__mobwithDestroyed) {
                         console.log('[MobWith] Timer callback skipped (destroyed)');
                         if (timer) {
                             clearInterval(timer);
                             timer = null;
                         }
                         return;
                     }

                     requestResize();

                     count++;

                     if (
                         count >= 40
                     ) {
                         clearInterval(
                             timer
                         );
                         timer = null;
                     }

                 },
                 250
             );
     };

     // ✅ Container가 DOM에서 제거되는지 감지 (clearAd 대응)
     if (container.parentElement) {
         containerObserver = new MutationObserver(function(mutations) {
             if (destroyed || container.__mobwithDestroyed) {
                 console.log('[MobWith] ContainerObserver callback skipped (destroyed)');
                 return;
             }
             
             for (let i = 0; i < mutations.length; i++) {
                 const mutation = mutations[i];
                 for (let j = 0; j < mutation.removedNodes.length; j++) {
                     const removedNode = mutation.removedNodes[j];
                     if (removedNode === container || (removedNode.contains && removedNode.contains(container))) {
                         console.log('[MobWith] Container removed from DOM, cleaning up...');
                         cleanup();
                         return;
                     }
                 }
             }
         });
         
         containerObserver.observe(container.parentElement, { childList: true, subtree: true });
     }

     // ✅ Viewport 크기 변경 감지 (가로 사이즈 변경 시 높이 재측정)
     let resizeTimeout = null;
     viewportResizeHandler = function() {
         if (destroyed || container.__mobwithDestroyed) {
             console.log('[MobWith] Viewport resize handler skipped (destroyed)');
             return;
         }
         
         if (resizeTimeout) clearTimeout(resizeTimeout);
         
         resizeTimeout = setTimeout(function() {
             if (destroyed || container.__mobwithDestroyed) {
                 console.log('[MobWith] Viewport resize timeout skipped (destroyed)');
                 return;
             }
             
             const currentViewportWidth = window.innerWidth;
             
             if (currentViewportWidth !== lastViewportWidth) {
                 console.log('[MobWith] Viewport width changed:', lastViewportWidth, '→', currentViewportWidth);
                 lastViewportWidth = currentViewportWidth;
                 
                 // ✅ 가로 사이즈 재적용
                 applyResponsiveWidth();
                 
                 // ✅ Observer 재활성화 (높이 재측정 필요)
                 reactivateObservers();
                 
                 setTimeout(function() {
                     if (destroyed || container.__mobwithDestroyed) return;
                     requestResize();
                 }, 150);
             }
         }, 100);
     };
     
     window.addEventListener('resize', viewportResizeHandler);

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

