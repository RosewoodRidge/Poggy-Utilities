/* ============================================
   POGGY FINDER - Frontend Logic
   Search, filter, autofill, waypoint setting
   Nearest-sort by player distance
   ============================================ */

(function () {
    'use strict';

    // ========================================
    // STATE
    // ========================================
    let allLocations = [];
    let allCategories = ['All'];
    let currentFilter = '';
    let currentCategory = 'All';
    let sortNearest = true;
    let playerPos = { x: 0, y: 0, z: 0 };

    // DOM refs (set after DOMContentLoaded or on first open)
    let overlay, panel, searchInput, categorySelect,
        resultsList, infoText, emptyState, nearestBtn, clearWaypointBtn;

    // ========================================
    // CATEGORY → ICON MAPPING
    // ========================================
    const categoryIcons = {
        'Doctor':          { icon: '+',  css: 'cat-icon-doctor' },
        'Sheriff':         { icon: '★',  css: 'cat-icon-sheriff' },
        'General Store':   { icon: '■',  css: 'cat-icon-general' },
        'Gunsmith':        { icon: '⚙',  css: 'cat-icon-gunsmith' },
        'Butcher':         { icon: '✦',  css: 'cat-icon-butcher' },
        'Fish Market':     { icon: '◆',  css: 'cat-icon-fish' },
        'Seeds & Farming': { icon: '✿',  css: 'cat-icon-seeds' },
        'Camp Outfitter':  { icon: '▲',  css: 'cat-icon-camp' },
        'Pet Store':       { icon: '♥',  css: 'cat-icon-pet' },
        'Ranch Supply':    { icon: '◈',  css: 'cat-icon-ranch' },
        'Blacksmith':      { icon: '⚒',  css: 'cat-icon-blacksmith' },
        'Clothing':        { icon: '◇',  css: 'cat-icon-clothing' },
        'Wardrobe':        { icon: '▢',  css: 'cat-icon-wardrobe' },
        'Saloon':          { icon: '♠',  css: 'cat-icon-saloon' },
        'Horse Supply':    { icon: '♞',  css: 'cat-icon-horse' },
        'Stable':          { icon: '♞',  css: 'cat-icon-stable' },
        'Prison':          { icon: '▣',  css: 'cat-icon-prison' },
        'Player Shop':     { icon: '$',  css: 'cat-icon-player' },
        'Barber':          { icon: '✂',  css: 'cat-icon-barber' },
        'Post Office':     { icon: '✉',  css: 'cat-icon-post' },
        'Bank':            { icon: '⊕',  css: 'cat-icon-bank' },
        'Hotel':           { icon: '⌂',  css: 'cat-icon-hotel' },
        'Balloon Taxi':    { icon: '⬆',  css: 'cat-icon-balloon' },
        'Public Job':      { icon: '⛏',  css: 'cat-icon-publicjob' },
        'Delivery Job':    { icon: '⚐',  css: 'cat-icon-deliveryjob' },
        'Contract Job':    { icon: '⚔',  css: 'cat-icon-contractjob' },
        'Legend Hunter':   { icon: '☠',  css: 'cat-icon-legendhunter' },
    };

    function getIconInfo(category) {
        return categoryIcons[category] || { icon: '●', css: 'cat-icon-default' };
    }

    // ========================================
    // DISTANCE CALCULATION (2D, game units)
    // ========================================
    function distance2D(x1, y1, x2, y2) {
        var dx = x1 - x2;
        var dy = y1 - y2;
        return Math.sqrt(dx * dx + dy * dy);
    }

    function getDistanceLabel(dist) {
        // Convert game units to a readable string
        // In RDR2/RedM, 1 game unit ≈ 1 meter
        if (dist < 1000) {
            return Math.round(dist) + 'm';
        }
        return (dist / 1000).toFixed(1) + 'km';
    }

    // ========================================
    // INITIALIZE DOM REFERENCES
    // ========================================
    function initDom() {
        overlay       = document.getElementById('finder-overlay');
        panel         = document.getElementById('finder-panel');
        searchInput   = document.getElementById('finder-search');
        categorySelect= document.getElementById('finder-category');
        resultsList   = document.getElementById('finder-results');
        infoText      = document.getElementById('finder-info');
        emptyState    = document.getElementById('finder-empty');
        nearestBtn    = document.getElementById('finder-nearest');
        clearWaypointBtn = document.getElementById('finder-clear-waypoint');
    }

    // ========================================
    // HIGHLIGHT MATCHING TEXT
    // ========================================
    function highlightMatch(text, query) {
        if (!query) return escapeHtml(text);
        const lower = text.toLowerCase();
        const qLower = query.toLowerCase();
        const idx = lower.indexOf(qLower);
        if (idx === -1) return escapeHtml(text);
        const before = text.substring(0, idx);
        const match  = text.substring(idx, idx + query.length);
        const after  = text.substring(idx + query.length);
        return escapeHtml(before) + '<mark>' + escapeHtml(match) + '</mark>' + escapeHtml(after);
    }

    function escapeHtml(str) {
        const div = document.createElement('div');
        div.textContent = str;
        return div.innerHTML;
    }

    // ========================================
    // FILTER & SORT & RENDER
    // ========================================
    function getFilteredLocations() {
        const query = currentFilter.toLowerCase().trim();
        const cat   = currentCategory;

        var filtered = allLocations.filter(function (loc) {
            // Category filter
            if (cat !== 'All' && loc.category !== cat) return false;
            // Text filter (search name and category)
            if (query) {
                const nameMatch = loc.name.toLowerCase().indexOf(query) !== -1;
                const catMatch  = loc.category.toLowerCase().indexOf(query) !== -1;
                if (!nameMatch && !catMatch) return false;
            }
            return true;
        });

        // Sort
        if (sortNearest) {
            filtered.sort(function (a, b) {
                var dA = distance2D(a.x, a.y, playerPos.x, playerPos.y);
                var dB = distance2D(b.x, b.y, playerPos.x, playerPos.y);
                return dA - dB;
            });
        } else {
            filtered.sort(function (a, b) {
                return a.name.localeCompare(b.name);
            });
        }

        return filtered;
    }

    function renderResults() {
        if (!resultsList) return;

        const filtered = getFilteredLocations();
        resultsList.innerHTML = '';

        if (filtered.length === 0) {
            emptyState.classList.add('visible');
            infoText.textContent = 'No results';
        } else {
            emptyState.classList.remove('visible');
            const total = allLocations.length;
            infoText.textContent = filtered.length + ' of ' + total + ' locations';

            filtered.forEach(function (loc) {
                const item = document.createElement('div');
                item.className = 'finder-item';
                item.setAttribute('data-x', loc.x);
                item.setAttribute('data-y', loc.y);
                item.setAttribute('data-name', loc.name);

                const iconInfo = getIconInfo(loc.category);
                const dist = distance2D(loc.x, loc.y, playerPos.x, playerPos.y);
                const distText = getDistanceLabel(dist);

                item.innerHTML =
                    '<div class="finder-item-icon ' + iconInfo.css + '">' + iconInfo.icon + '</div>' +
                    '<div class="finder-item-info">' +
                        '<div class="finder-item-name">' + highlightMatch(loc.name, currentFilter) + '</div>' +
                        '<div class="finder-item-meta">' +
                            '<span class="finder-item-category">' + escapeHtml(loc.category) + '</span>' +
                            '<span class="finder-item-distance">' + distText + '</span>' +
                        '</div>' +
                    '</div>' +
                    '<div class="finder-item-arrow">›</div>';

                item.addEventListener('click', function () {
                    onSelectLocation(loc);
                });

                resultsList.appendChild(item);
            });
        }
    }

    // ========================================
    // POPULATE CATEGORY DROPDOWN
    // ========================================
    function populateCategories() {
        if (!categorySelect) return;
        categorySelect.innerHTML = '';
        allCategories.forEach(function (cat) {
            const opt = document.createElement('option');
            opt.value = cat;
            opt.textContent = cat;
            categorySelect.appendChild(opt);
        });
        categorySelect.value = currentCategory;
    }

    // ========================================
    // ACTIONS
    // ========================================
    function onSelectLocation(loc) {
        // Send waypoint to client Lua (include z for RDR3 native)
        $.post('https://poggy_util/setWaypoint', JSON.stringify({
            x: loc.x,
            y: loc.y,
            z: loc.z,
            name: loc.name
        }));
    }

    function clearWaypoint() {
        $.post('https://poggy_util/clearWaypoint', JSON.stringify({}));
    }

    function closeFinder() {
        if (overlay) overlay.classList.remove('visible');
        currentFilter = '';
        currentCategory = 'All';
        sortNearest = true;
        if (searchInput) searchInput.value = '';
        if (nearestBtn) nearestBtn.classList.add('active');
        $.post('https://poggy_util/closeFinder', JSON.stringify({}));
    }

    function toggleNearest() {
        sortNearest = !sortNearest;
        if (nearestBtn) {
            nearestBtn.classList.toggle('active', sortNearest);
        }
        renderResults();
    }

    // ========================================
    // OPEN FINDER
    // ========================================
    function openFinder(data) {
        initDom();
        if (!overlay) return;

        // Load data
        allLocations  = data.locations || [];
        allCategories = data.categories || ['All'];
        currentFilter = '';
        currentCategory = 'All';
        sortNearest = true;

        // Store player position for distance calculations
        playerPos.x = data.playerX || 0;
        playerPos.y = data.playerY || 0;
        playerPos.z = data.playerZ || 0;

        // Sort locations alphabetically by default
        allLocations.sort(function (a, b) {
            return a.name.localeCompare(b.name);
        });

        populateCategories();
        if (nearestBtn) nearestBtn.classList.add('active');
        renderResults();

        overlay.classList.add('visible');

        // Focus search input after a brief delay (NUI focus needs a moment)
        setTimeout(function () {
            if (searchInput) searchInput.focus();
        }, 50);
    }

    // ========================================
    // EVENT LISTENERS
    // ========================================
    document.addEventListener('DOMContentLoaded', function () {
        initDom();

        // Search input - filter as you type
        if (searchInput) {
            searchInput.addEventListener('input', function () {
                currentFilter = this.value;
                renderResults();
            });

            // Escape key to close
            searchInput.addEventListener('keydown', function (e) {
                if (e.key === 'Escape') {
                    closeFinder();
                }
            });
        }

        // Category dropdown
        if (categorySelect) {
            categorySelect.addEventListener('change', function () {
                currentCategory = this.value;
                renderResults();
            });
        }

        // Nearest toggle button
        if (nearestBtn) {
            nearestBtn.addEventListener('click', function () {
                toggleNearest();
            });
        }

        // Close button
        var closeBtn = document.getElementById('finder-close');
        if (closeBtn) {
            closeBtn.addEventListener('click', function () {
                closeFinder();
            });
        }

        // Clear waypoint button
        if (clearWaypointBtn) {
            clearWaypointBtn.addEventListener('click', function () {
                clearWaypoint();
            });
        }

        // Escape key anywhere
        document.addEventListener('keydown', function (e) {
            if (e.key === 'Escape' && overlay && overlay.classList.contains('visible')) {
                closeFinder();
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
            case 'openFinder':
                openFinder(data);
                break;

            case 'closeFinder':
                initDom();
                if (overlay) overlay.classList.remove('visible');
                break;
        }
    });

})();
