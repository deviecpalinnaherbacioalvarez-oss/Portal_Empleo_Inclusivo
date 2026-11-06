(() => {
    'use strict';
    const $ = (selector, root = document) => root.querySelector(selector);
    const $$ = (selector, root = document) => [...root.querySelectorAll(selector)];
    const normalize = value => String(value || '').normalize('NFD').replace(/[\u0300-\u036f]/g, '').toLowerCase().trim();
    const read = (key, fallback) => { try { return JSON.parse(localStorage.getItem(key)) ?? fallback; } catch (_) { return fallback; } };
    const write = (key, value) => { try { localStorage.setItem(key, JSON.stringify(value)); return true; } catch (_) { return false; } };
    let toastTimer;
    function notify(message) {
        const toast = $('#toast');
        if (!toast) return;
        toast.textContent = message;
        toast.hidden = false;
        clearTimeout(toastTimer);
        toastTimer = setTimeout(() => { toast.hidden = true; }, 4500);
    }
    const storedPreferences = read('incluyelab.preferences', {});
    const preferences = storedPreferences && typeof storedPreferences === 'object' && !Array.isArray(storedPreferences) ? storedPreferences : {};
    const classes = { contrast: 'high-contrast', font: 'readable-font', large: 'large-text' };
    $$('[data-preference]').forEach(button => {
        const key = button.dataset.preference;
        const apply = () => {
            document.documentElement.classList.toggle(classes[key], !!preferences[key]);
            button.setAttribute('aria-pressed', String(!!preferences[key]));
        };
        apply();
        button.addEventListener('click', () => { preferences[key] = !preferences[key]; write('incluyelab.preferences', preferences); apply(); });
    });
    $('.menu-toggle')?.addEventListener('click', event => {
        const button = event.currentTarget;
        const open = $('#main-nav').classList.toggle('is-open');
        button.setAttribute('aria-expanded', String(open));
        button.setAttribute('aria-label', open ? 'Cerrar menú' : 'Abrir menú');
    });
    $$('[data-toggle-password]').forEach(button => {
        const input = document.getElementById(button.dataset.togglePassword);
        if (!input) return;
        const update = () => {
            const visible = input.type === 'text';
            button.setAttribute('aria-pressed', String(visible));
            button.setAttribute('aria-label', visible ? 'Ocultar contraseña' : 'Mostrar contraseña');
            button.title = button.getAttribute('aria-label');
            button.innerHTML = '<svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true" focusable="false" data-password-icon="' + (visible ? 'eye' : 'eye-off') + '"><path d="M2 12s3.5-7 10-7 10 7 10 7-3.5 7-10 7S2 12 2 12Z"/><circle cx="12" cy="12" r="3"/>' + (visible ? '' : '<path data-eye-slash d="m3 3 18 18"/>') + '</svg>';
        };
        button.addEventListener('click', () => {
            input.type = input.type === 'password' ? 'text' : 'password';
            update();
        });
        update();
    });
    $$('[data-password-rules]').forEach(list => {
        const input = document.getElementById(list.dataset.passwordRules);
        if (!input) return;
        const tests = {
            length: value => value.length >= 8 && value.length <= 100,
            upper: value => /[A-Z]/.test(value),
            lower: value => /[a-z]/.test(value),
            digit: value => /[0-9]/.test(value),
            special: value => /[^A-Za-z0-9\s]/.test(value),
            spaces: value => !/\s/.test(value)
        };
        const update = () => {
            const value = input.value;
            let valid = value.length > 0;
            $$('[data-rule]', list).forEach(item => {
                const met = tests[item.dataset.rule](value);
                item.classList.toggle('is-met', met);
                valid = valid && met;
            });
            input.setCustomValidity(value && !valid ? 'La contraseña todavía no cumple todos los requisitos.' : '');
        };
        input.addEventListener('input', update); update();
    });
    $$('[data-table-search]').forEach(input => input.addEventListener('input', () => {
        const table = document.getElementById(input.dataset.tableSearch);
        let count = 0;
        $$('tbody tr:not(.table-empty)', table).forEach(row => { row.hidden = !normalize(row.textContent).includes(normalize(input.value)); if (!row.hidden) count++; });
        let empty = $('.table-empty', table);
        if (!empty) { empty = document.createElement('tr'); empty.className = 'table-empty'; const cell = document.createElement('td'); cell.colSpan = $$('thead th', table).length; cell.textContent = 'No se encontraron resultados.'; empty.append(cell); $('tbody', table).append(empty); }
        empty.hidden = count > 0;
    }));
    const roleSelect = $('#rol');
    if (roleSelect && $('#nombre-label')) {
        const updateName = () => { $('#nombre-label').textContent = roleSelect.value === 'EMPRESA' ? 'Razón social de la empresa' : 'Nombre completo'; };
        updateName(); roleSelect.addEventListener('change', updateName);
    }
    window.lucide?.createIcons();
    const grid = $('#offer-grid');
    if (!grid) return;
    const cards = $$('.offer-card', grid);
    const stored = read('incluyelab.saved', []);
    const saved = new Set(Array.isArray(stored) ? stored.map(String) : []);
    let onlySaved = false;
    function updateSaved() {
        $$('[data-save]').forEach(button => {
            const active = saved.has(button.dataset.save);
            button.setAttribute('aria-pressed', String(active));
            const title = button.closest('.offer-card').dataset.title;
            button.setAttribute('aria-label', (active ? 'Quitar de guardadas: ' : 'Guardar ') + title);
            button.title = active ? 'Quitar de guardadas' : 'Guardar oferta';
        });
        $('#saved-count').textContent = cards.filter(card => saved.has(card.dataset.id)).length;
    }
    function filterSaved(sync = true) {
        let count = 0;
        cards.forEach(card => {
            const visible = !onlySaved || saved.has(card.dataset.id);
            card.hidden = !visible;
            if (visible) count++;
        });
        if (onlySaved) $('#result-count').textContent = count + (count === 1 ? ' empleo guardado en esta página' : ' empleos guardados en esta página');
        $('#empty-results').hidden = onlySaved ? count > 0 : cards.length > 0;
        $('#saved-note').hidden = !onlySaved;
        if (sync) {
            const url = new URL(window.location.href);
            url.searchParams.delete('guardadas');
            if (onlySaved) url.searchParams.set('guardadas','1');
            history.replaceState({}, '', url);
        }
    }
    function restoreFilters() {
        const params = new URL(window.location.href).searchParams;
        onlySaved = params.get('guardadas') === '1';
        $('.saved-filter').setAttribute('aria-pressed', String(onlySaved));
        filterSaved(false);
    }
    function clearFilters() {
        window.location.assign((document.body.dataset.context || '') + '/inicio#ofertas');
    }
    $('#clear-filters').addEventListener('click', clearFilters);
    $('#reset-results').addEventListener('click', clearFilters);
    $$('.filters input, .filters select, #sort').forEach(input => input.addEventListener('change', () => $('#job-search').requestSubmit()));
    $('#q').addEventListener('search', () => $('#job-search').requestSubmit());
    $('.saved-filter').addEventListener('click', () => { onlySaved = !onlySaved; $('.saved-filter').setAttribute('aria-pressed', String(onlySaved)); filterSaved(); });
    $$('[data-save]').forEach(button => button.addEventListener('click', () => {
        const id = button.dataset.save;
        if (saved.has(id)) saved.delete(id); else saved.add(id);
        const persisted = write('incluyelab.saved', [...saved]);
        updateSaved(); filterSaved();
        notify(persisted ? (saved.has(id) ? 'Oferta guardada en este navegador.' : 'Oferta eliminada de guardadas.') : 'Tu navegador no permite guardar esta preferencia. Se conservará mientras esta página esté abierta.');
    }));
    const dialog = $('#job-dialog');
    function openDetail(id, sync = true) {
        const template = document.getElementById('detail-' + id);
        if (!template) return;
        $('#dialog-content').replaceChildren(template.content.cloneNode(true));
        window.lucide?.createIcons();
        if (!dialog.open) dialog.showModal();
        if (sync) { const url = new URL(window.location.href); url.searchParams.set('oferta',id); history.replaceState({},'',url); }
    }
    $$('[data-detail]').forEach(button => button.addEventListener('click', event => { event.preventDefault(); openDetail(button.dataset.detail); }));
    $('[data-close-dialog]').addEventListener('click', () => dialog.close());
    dialog.addEventListener('click', event => { if (event.target === dialog) { const r = dialog.getBoundingClientRect(); if (event.clientX < r.left || event.clientX > r.right || event.clientY < r.top || event.clientY > r.bottom) dialog.close(); } });
    dialog.addEventListener('close', () => { const url = new URL(window.location.href); url.searchParams.delete('oferta'); history.replaceState({},'',url); });
    window.addEventListener('popstate', () => { restoreFilters(); const id = new URL(window.location.href).searchParams.get('oferta'); if (id) openDetail(id,false); else if (dialog.open) dialog.close(); });
    updateSaved(); restoreFilters();
    const initialOffer = new URL(window.location.href).searchParams.get('oferta');
    if (initialOffer) openDetail(initialOffer, false);
})();
