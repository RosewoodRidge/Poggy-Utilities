/* ============================================
   POGGY SELL FINDER - Frontend Logic
   Two-screen flow: Inventory Items → Shops
   Sort by distance / price, item images
   ============================================ */

(function () {
    'use strict';

    // ========================================
    // STATE
    // ========================================
    let allItems = [];          // {name, label, count, shops: [{shopName, shopType, price, x, y, z}]}
    let selectedItem = null;    // Currently selected item (shops view)
    let currentScreen = 'items'; // 'items' | 'shops'
    let currentFilter = '';
    let shopSortMode = 'distance'; // 'distance' | 'price'
    let playerPos = { x: 0, y: 0, z: 0 };

    // DOM refs
    let overlay, panel, searchInput, resultsDiv, infoText,
        emptyDiv, loadingDiv, backBtn, sortRow, selectedItemDiv,
        clearWaypointBtn;

    // ========================================
    // ITEM IMAGE URL (from vorp_inventory)
    // ========================================
    function getItemImageUrl(itemName) {
        return 'nui://vorp_inventory/html/img/items/' + encodeURIComponent(itemName) + '.png';
    }

    // ========================================
    // DISTANCE CALCULATION
    // ========================================
    function distance2D(x1, y1, x2, y2) {
        var dx = x1 - x2;
        var dy = y1 - y2;
        return Math.sqrt(dx * dx + dy * dy);
    }

    function getDistanceLabel(dist) {
        if (dist < 1000) {
            return Math.round(dist) + 'm';
        }
        return (dist / 1000).toFixed(1) + 'km';
    }

    // ========================================
    // PRICE FORMATTING
    // ========================================
    function formatPrice(price) {
        var num = parseFloat(price);
        if (isNaN(num)) return '$?.??';
        return '$' + num.toFixed(2);
    }

    // ========================================
    // INIT DOM
    // ========================================
    function initDom() {
        overlay          = document.getElementById('sell-overlay');
        panel            = document.getElementById('sell-panel');
        searchInput      = document.getElementById('sell-search');
        resultsDiv       = document.getElementById('sell-results');
        infoText         = document.getElementById('sell-info');
        emptyDiv         = document.getElementById('sell-empty');
        loadingDiv       = document.getElementById('sell-loading');
        backBtn          = document.getElementById('sell-back');
        sortRow          = document.getElementById('sell-sort-row');
        selectedItemDiv  = document.getElementById('sell-selected-item');
        clearWaypointBtn = document.getElementById('sell-clear-waypoint');
    }

    // ========================================
    // ESCAPE HTML
    // ========================================
    function escapeHtml(str) {
        var div = document.createElement('div');
        div.textContent = str;
        return div.innerHTML;
    }

    // ========================================
    // HIGHLIGHT MATCHING TEXT
    // ========================================
    function highlightMatch(text, query) {
        if (!query) return escapeHtml(text);
        var lower = text.toLowerCase();
        var qLower = query.toLowerCase();
        var idx = lower.indexOf(qLower);
        if (idx === -1) return escapeHtml(text);
        var before = text.substring(0, idx);
        var match  = text.substring(idx, idx + query.length);
        var after  = text.substring(idx + query.length);
        return escapeHtml(before) + '<mark>' + escapeHtml(match) + '</mark>' + escapeHtml(after);
    }

    // ========================================
    // IMAGE WITH FALLBACK
    // ========================================
    function createItemImage(itemName) {
        var wrapper = document.createElement('div');
        var img = document.createElement('img');
        img.src = getItemImageUrl(itemName);
        img.alt = '';
        img.loading = 'lazy';
        img.onerror = function () {
            this.style.display = 'none';
            var fallback = document.createElement('span');
            fallback.className = 'sell-img-fallback';
            fallback.textContent = '▪';
            this.parentElement.appendChild(fallback);
        };
        wrapper.appendChild(img);
        return wrapper;
    }

    // ========================================
    // RENDER ITEMS SCREEN
    // ========================================
    function renderItems() {
        if (!resultsDiv) return;
        resultsDiv.innerHTML = '';

        var query = currentFilter.toLowerCase().trim();

        // Filter items
        var filtered = allItems.filter(function (item) {
            if (!query) return true;
            return item.label.toLowerCase().indexOf(query) !== -1 ||
                   item.name.toLowerCase().indexOf(query) !== -1;
        });

        // Sort: items with highest best-price first (most valuable)
        filtered.sort(function (a, b) {
            var bestA = getBestPrice(a.shops);
            var bestB = getBestPrice(b.shops);
            return bestB - bestA;
        });

        if (filtered.length === 0) {
            if (allItems.length === 0) {
                showEmpty('No Sellable Items',
                    'None of the items in your inventory are currently being bought by any shops.');
            } else {
                showEmpty('No Matches',
                    'No items match your search. Try different keywords.');
            }
            infoText.textContent = '';
            return;
        }

        hideEmpty();
        infoText.textContent = filtered.length + ' sellable item' + (filtered.length !== 1 ? 's' : '') + ' in your inventory';

        filtered.forEach(function (item) {
            var card = document.createElement('div');
            card.className = 'sell-item';

            var imgDiv = document.createElement('div');
            imgDiv.className = 'sell-item-img';
            imgDiv.appendChild(createItemImage(item.name));

            var infoDiv = document.createElement('div');
            infoDiv.className = 'sell-item-info';

            var nameDiv = document.createElement('div');
            nameDiv.className = 'sell-item-name';
            nameDiv.innerHTML = highlightMatch(item.label, currentFilter);

            var metaDiv = document.createElement('div');
            metaDiv.className = 'sell-item-meta';

            var countSpan = document.createElement('span');
            countSpan.className = 'sell-item-count';
            countSpan.textContent = '×' + item.count + ' in inventory';

            var shopsSpan = document.createElement('span');
            shopsSpan.className = 'sell-item-shops';
            shopsSpan.textContent = item.shops.length + ' shop' + (item.shops.length !== 1 ? 's' : '') + ' buying';

            var bestPrice = getBestPrice(item.shops);
            var priceSpan = document.createElement('span');
            priceSpan.className = 'sell-item-best-price';
            priceSpan.textContent = 'Best: ' + formatPrice(bestPrice);

            metaDiv.appendChild(countSpan);
            metaDiv.appendChild(shopsSpan);
            metaDiv.appendChild(priceSpan);

            infoDiv.appendChild(nameDiv);
            infoDiv.appendChild(metaDiv);

            var arrowDiv = document.createElement('div');
            arrowDiv.className = 'sell-item-arrow';
            arrowDiv.textContent = '›';

            card.appendChild(imgDiv);
            card.appendChild(infoDiv);
            card.appendChild(arrowDiv);

            card.addEventListener('click', function () {
                selectItem(item);
            });

            resultsDiv.appendChild(card);
        });
    }

    // ========================================
    // RENDER SHOPS SCREEN
    // ========================================
    function renderShops() {
        if (!resultsDiv || !selectedItem) return;
        resultsDiv.innerHTML = '';

        var query = currentFilter.toLowerCase().trim();
        var shops = selectedItem.shops.slice(); // copy

        // Filter shops by name
        if (query) {
            shops = shops.filter(function (s) {
                return s.shopName.toLowerCase().indexOf(query) !== -1 ||
                       s.shopType.toLowerCase().indexOf(query) !== -1;
            });
        }

        // Sort shops
        if (shopSortMode === 'price') {
            shops.sort(function (a, b) {
                return parseFloat(b.price) - parseFloat(a.price);
            });
        } else {
            // Distance sort (default)
            shops.sort(function (a, b) {
                var dA = distance2D(a.x, a.y, playerPos.x, playerPos.y);
                var dB = distance2D(b.x, b.y, playerPos.x, playerPos.y);
                return dA - dB;
            });
        }

        if (shops.length === 0) {
            showEmpty('No Shops Found', 'No shops match your search.');
            infoText.textContent = '';
            return;
        }

        hideEmpty();
        infoText.textContent = shops.length + ' shop' + (shops.length !== 1 ? 's' : '') + ' buying this item';

        // Update selected item header
        updateSelectedItemHeader();

        shops.forEach(function (shop, idx) {
            var card = document.createElement('div');
            card.className = 'sell-shop';

            // Rank badge
            var rankDiv = document.createElement('div');
            rankDiv.className = 'sell-shop-rank';
            rankDiv.textContent = idx + 1;

            // Info
            var infoDiv = document.createElement('div');
            infoDiv.className = 'sell-shop-info';

            var nameDiv = document.createElement('div');
            nameDiv.className = 'sell-shop-name';
            nameDiv.innerHTML = highlightMatch(shop.shopName, currentFilter);

            var typeDiv = document.createElement('div');
            typeDiv.className = 'sell-shop-type' + (shop.shopType === 'Player Shop' ? ' player-shop' : '');
            typeDiv.textContent = shop.shopType;

            infoDiv.appendChild(nameDiv);
            infoDiv.appendChild(typeDiv);

            // Price & Distance
            var rightDiv = document.createElement('div');
            rightDiv.className = 'sell-shop-right';

            var priceDiv = document.createElement('div');
            priceDiv.className = 'sell-shop-price';
            priceDiv.textContent = formatPrice(shop.price);

            var dist = distance2D(shop.x, shop.y, playerPos.x, playerPos.y);
            var distDiv = document.createElement('div');
            distDiv.className = 'sell-shop-distance';
            distDiv.textContent = getDistanceLabel(dist);

            rightDiv.appendChild(priceDiv);
            rightDiv.appendChild(distDiv);

            // Arrow
            var arrowDiv = document.createElement('div');
            arrowDiv.className = 'sell-shop-arrow';
            arrowDiv.textContent = '›';

            card.appendChild(rankDiv);
            card.appendChild(infoDiv);
            card.appendChild(rightDiv);
            card.appendChild(arrowDiv);

            card.addEventListener('click', function () {
                onSelectShop(shop);
            });

            resultsDiv.appendChild(card);
        });
    }

    // ========================================
    // SELECTED ITEM HEADER (Shops screen)
    // ========================================
    function updateSelectedItemHeader() {
        if (!selectedItemDiv || !selectedItem) return;

        var imgContainer = document.getElementById('sell-selected-img');
        imgContainer.innerHTML = '';
        imgContainer.appendChild(createItemImage(selectedItem.name));

        document.getElementById('sell-selected-name').textContent = selectedItem.label;
        document.getElementById('sell-selected-count').textContent = '×' + selectedItem.count + ' in inventory';

        var prices = selectedItem.shops.map(function (s) { return parseFloat(s.price); });
        var minP = Math.min.apply(null, prices);
        var maxP = Math.max.apply(null, prices);
        var rangeText = (minP === maxP) ?
            formatPrice(minP) + ' per unit' :
            formatPrice(minP) + ' – ' + formatPrice(maxP) + ' per unit';
        document.getElementById('sell-selected-price-range').textContent = rangeText;

        selectedItemDiv.classList.add('visible');
    }

    // ========================================
    // SCREEN TRANSITIONS
    // ========================================
    function showItemsScreen() {
        currentScreen = 'items';
        selectedItem = null;
        currentFilter = '';
        shopSortMode = 'distance';

        if (searchInput) {
            searchInput.value = '';
            searchInput.placeholder = 'Search your items...';
        }
        if (backBtn) backBtn.classList.remove('visible');
        if (sortRow) sortRow.classList.remove('visible');
        if (selectedItemDiv) selectedItemDiv.classList.remove('visible');

        document.getElementById('sell-title').textContent = 'SELL FINDER';
        document.getElementById('sell-subtitle').textContent = 'Items shops are buying';

        renderItems();
    }

    function selectItem(item) {
        selectedItem = item;
        currentScreen = 'shops';
        currentFilter = '';
        shopSortMode = 'distance';

        if (searchInput) {
            searchInput.value = '';
            searchInput.placeholder = 'Search shops...';
        }
        if (backBtn) backBtn.classList.add('visible');
        if (sortRow) sortRow.classList.add('visible');

        document.getElementById('sell-title').textContent = 'WHERE TO SELL';
        document.getElementById('sell-subtitle').textContent = escapeHtml(item.label);

        updateSortButtons();
        renderShops();

        if (searchInput) {
            setTimeout(function () { searchInput.focus(); }, 50);
        }
    }

    // ========================================
    // SORT BUTTONS
    // ========================================
    function updateSortButtons() {
        var distBtn = document.getElementById('sell-sort-distance');
        var priceBtn = document.getElementById('sell-sort-price');
        if (!distBtn || !priceBtn) return;

        distBtn.classList.toggle('active', shopSortMode === 'distance');
        priceBtn.classList.toggle('active', shopSortMode === 'price');
    }

    // ========================================
    // HELPER FUNCTIONS
    // ========================================
    function getBestPrice(shops) {
        if (!shops || shops.length === 0) return 0;
        var best = 0;
        shops.forEach(function (s) {
            var p = parseFloat(s.price);
            if (p > best) best = p;
        });
        return best;
    }

    function showEmpty(title, hint) {
        if (!emptyDiv) return;
        document.getElementById('sell-empty-text').textContent = title || 'No results';
        document.getElementById('sell-empty-hint').textContent = hint || '';
        emptyDiv.classList.add('visible');
    }

    function hideEmpty() {
        if (emptyDiv) emptyDiv.classList.remove('visible');
    }

    function showLoading() {
        if (loadingDiv) loadingDiv.classList.add('visible');
        if (resultsDiv) resultsDiv.style.display = 'none';
    }

    function hideLoading() {
        if (loadingDiv) loadingDiv.classList.remove('visible');
        if (resultsDiv) resultsDiv.style.display = '';
    }

    // ========================================
    // ACTIONS
    // ========================================
    function onSelectShop(shop) {
        $.post('https://poggy_util/sellSetWaypoint', JSON.stringify({
            x: shop.x,
            y: shop.y,
            z: shop.z,
            shopName: shop.shopName
        }));
    }

    function closeSell() {
        if (overlay) overlay.classList.remove('visible');
        currentFilter = '';
        currentScreen = 'items';
        selectedItem = null;
        shopSortMode = 'distance';
        if (searchInput) searchInput.value = '';
        hideEmpty();
        hideLoading();
        $.post('https://poggy_util/closeSell', JSON.stringify({}));
    }

    function clearWaypoint() {
        $.post('https://poggy_util/sellClearWaypoint', JSON.stringify({}));
    }

    // ========================================
    // OPEN SELL
    // ========================================
    function openSell(data) {
        initDom();
        if (!overlay) return;

        playerPos.x = data.playerX || 0;
        playerPos.y = data.playerY || 0;
        playerPos.z = data.playerZ || 0;

        overlay.classList.add('visible');

        if (data.loading) {
            showLoading();
            if (backBtn) backBtn.classList.remove('visible');
            if (sortRow) sortRow.classList.remove('visible');
            if (selectedItemDiv) selectedItemDiv.classList.remove('visible');
            infoText.textContent = '';
            document.getElementById('sell-title').textContent = 'SELL FINDER';
            document.getElementById('sell-subtitle').textContent = 'Checking your inventory...';
        }
    }

    // ========================================
    // RECEIVE DATA
    // ========================================
    function receiveSellData(data) {
        initDom();
        hideLoading();

        allItems = data.items || [];
        playerPos.x = data.playerX || playerPos.x;
        playerPos.y = data.playerY || playerPos.y;
        playerPos.z = data.playerZ || playerPos.z;

        document.getElementById('sell-subtitle').textContent = 'Items shops are buying';
        showItemsScreen();

        setTimeout(function () {
            if (searchInput) searchInput.focus();
        }, 50);
    }

    // ========================================
    // EVENT LISTENERS
    // ========================================
    document.addEventListener('DOMContentLoaded', function () {
        initDom();

        // Search input
        if (searchInput) {
            searchInput.addEventListener('input', function () {
                currentFilter = this.value;
                if (currentScreen === 'items') {
                    renderItems();
                } else {
                    renderShops();
                }
            });

            searchInput.addEventListener('keydown', function (e) {
                if (e.key === 'Escape') {
                    closeSell();
                }
            });
        }

        // Back button
        if (backBtn) {
            backBtn.addEventListener('click', function () {
                showItemsScreen();
            });
        }

        // Close button
        var closeBtn = document.getElementById('sell-close');
        if (closeBtn) {
            closeBtn.addEventListener('click', function () {
                closeSell();
            });
        }

        // Clear waypoint
        if (clearWaypointBtn) {
            clearWaypointBtn.addEventListener('click', function () {
                clearWaypoint();
            });
        }

        // Sort buttons
        $(document).on('click', '#sell-sort-distance', function () {
            shopSortMode = 'distance';
            updateSortButtons();
            renderShops();
        });

        $(document).on('click', '#sell-sort-price', function () {
            shopSortMode = 'price';
            updateSortButtons();
            renderShops();
        });

        // Escape key
        document.addEventListener('keydown', function (e) {
            if (e.key === 'Escape' && overlay && overlay.classList.contains('visible')) {
                if (currentScreen === 'shops') {
                    // Go back to items screen instead of closing
                    showItemsScreen();
                } else {
                    closeSell();
                }
            }
        });
    });

    // ========================================
    // NUI MESSAGE HANDLER
    // ========================================
    window.addEventListener('message', function (event) {
        var data = event.data;
        if (!data || !data.type) return;

        switch (data.type) {
            case 'openSell':
                openSell(data);
                break;

            case 'sellData':
                receiveSellData(data);
                break;

            case 'closeSell':
                initDom();
                if (overlay) overlay.classList.remove('visible');
                break;
        }
    });

})();
