/* Ayuda visual voluntaria. Mantiene el teclado nativo de formularios y widgets. */
(() => {
    'use strict';
    const all = (selector, root = document) => [...root.querySelectorAll(selector)];
    const status = message => all('[data-visual-status]').forEach(node => { node.textContent = message; });
    const visible = node => node.getClientRects().length > 0
        && getComputedStyle(node).visibility === 'visible'
        && !node.closest('[hidden], [inert], [aria-hidden="true"]');
    const modal = () => document.querySelector('dialog[open], .modal.show');
    const content = () => {
        const activeModal = modal();
        return activeModal?.querySelector('.dialog-content, .modal-body') || activeModal
            || document.querySelector('main, [role="main"]');
    };
    const main = document.querySelector('#contenido');
    if (main && !main.hasAttribute('tabindex')) main.tabIndex = -1;
    let settings = {};
    try {
        const saved = JSON.parse(localStorage.getItem('incluyelab.visual'));
        if (saved && typeof saved === 'object' && !Array.isArray(saved)) settings = saved;
    } catch (_) { /* La ayuda también funciona sin almacenamiento. */ }
    let arrows = settings.arrows === true;
    let readFocus = settings.readFocus === true;
    let muted = false;
    const save = () => {
        try { localStorage.setItem('incluyelab.visual', JSON.stringify({ arrows, readFocus })); }
        catch (_) { status('La preferencia se conservará solo mientras esta página esté abierta.'); }
    };
    const updateArrows = () => {
        document.documentElement.classList.toggle('arrow-navigation', arrows);
        all('[data-arrow-navigation]').forEach(button => button.setAttribute('aria-pressed', String(arrows)));
    };
    updateArrows();

    const supported = 'speechSynthesis' in window && typeof window.SpeechSynthesisUtterance === 'function';
    const synth = supported ? window.speechSynthesis : null;
    let generation = 0;
    let currentUtterance = null;
    let reading = false;
    let paused = false;
    let spanishVoice = null;
    const updateVoice = () => {
        const voices = synth.getVoices();
        spanishVoice = voices.find(voice => /^es[-_]PE$/i.test(voice.lang))
            || voices.find(voice => /^es(?:[-_]|$)/i.test(voice.lang)) || null;
    };
    const updateSpeechControls = () => {
        all('[data-read-page], [data-read-focus]').forEach(control => { control.disabled = !supported; });
        all('[data-read-pause]').forEach(button => {
            button.disabled = !reading;
            button.textContent = paused ? 'Continuar lectura' : 'Pausar lectura';
        });
        all('[data-read-stop]').forEach(button => { button.disabled = !reading; });
        all('[data-read-mute]').forEach(button => {
            button.disabled = !supported;
            button.setAttribute('aria-pressed', String(muted));
            button.setAttribute('aria-label', muted ? 'Activar lectura' : 'Silenciar lectura');
            button.title = muted ? 'Activar lectura' : 'Silenciar lectura';
        });
    };
    function stop(message = '') {
        generation++;
        reading = false;
        paused = false;
        currentUtterance = null;
        synth?.cancel();
        updateSpeechControls();
        if (message) status(message);
    }
    // Recoge solo texto visible y descripciones de imágenes. Nunca lee valores escritos.
    function textToRead(root) {
        if (!root) return '';
        const parts = [];
        const skip = 'script, style, template, noscript, input, textarea, select, [data-no-read], [data-visual-status]';
        const visit = node => {
            if (node.nodeType === Node.TEXT_NODE) {
                if (node.textContent.trim()) parts.push(node.textContent.trim());
                return;
            }
            if (!(node instanceof Element) || node.matches(skip) || !visible(node)) return;
            if (node.tagName === 'IMG') {
                if (node.alt.trim()) parts.push(node.alt.trim());
                return;
            }
            for (const child of node.childNodes) visit(child);
        };
        visit(root);
        return parts.join(' ').replace(/\s+/g, ' ').trim();
    }
    function speak(text, announce = true) {
        if (!supported) return;
        if (muted) return;
        stop();
        if (!text) { status('No hay contenido visible para leer.'); return; }
        // Frases cortas evitan que una página larga se pierda en una única locución.
        const chunks = text.match(/.{1,220}(?:\s|$)|\S{1,220}/g) || [text];
        const token = generation;
        reading = true;
        updateSpeechControls();
        if (announce) status('Lectura iniciada. Puedes pausarla o detenerla con Escape.');
        const next = index => {
            if (token !== generation) return;
            if (index >= chunks.length) {
                reading = false;
                currentUtterance = null;
                updateSpeechControls();
                if (announce) status('Lectura finalizada.');
                return;
            }
            const utterance = new SpeechSynthesisUtterance(chunks[index]);
            currentUtterance = utterance;
            utterance.lang = 'es-PE';
            if (spanishVoice) utterance.voice = spanishVoice;
            utterance.rate = 0.95;
            utterance.onend = () => next(index + 1);
            utterance.onerror = event => {
                if (token !== generation) return;
                stop(event.error === 'not-allowed'
                    ? 'El navegador bloqueó la voz. Pulsa Escuchar página para intentarlo otra vez.'
                    : 'No se pudo reproducir la voz. Comprueba las voces y el sonido de tu navegador.');
            };
            try { synth.speak(utterance); }
            catch (_) { stop('La voz no está disponible en este navegador. Puedes usar tu lector de pantalla.'); }
        };
        synth.resume();
        next(0);
    }
    if (supported) {
        updateVoice();
        synth.addEventListener('voiceschanged', updateVoice);
    } else {
        status('La voz no está disponible en este navegador. Puedes usar un lector de pantalla; el contraste, el texto y el teclado siguen disponibles.');
    }
    all('[data-read-focus]').forEach(input => {
        input.checked = readFocus;
        input.addEventListener('change', () => { readFocus = input.checked; save(); if (!readFocus) stop(); });
    });
    updateSpeechControls();
    document.addEventListener('click', event => {
        const button = event.target.closest('[data-read-page], [data-read-stop], [data-read-pause], [data-read-mute], [data-arrow-navigation]');
        if (!button || button.disabled) return;
        if (button.matches('[data-read-page]')) {
            muted = false;
            updateSpeechControls();
            speak(textToRead(content()));
        }
        if (button.matches('[data-read-stop]')) stop('Lectura detenida.');
        if (button.matches('[data-read-pause]')) {
            paused = !paused;
            if (paused) synth.pause(); else synth.resume();
            updateSpeechControls();
            status(paused ? 'Lectura en pausa.' : 'Lectura reanudada.');
        }
        if (button.matches('[data-read-mute]')) {
            muted = !muted;
            if (muted) stop('Lectura silenciada.');
            else status('Lectura activada. Usa las flechas para escuchar cada recuadro.');
            updateSpeechControls();
        }
        if (button.matches('[data-arrow-navigation]')) {
            arrows = !arrows;
            updateArrows();
            status(arrows ? 'Flechas activadas. Usa Tab dentro de los campos y Escape para detener la voz.' : 'Flechas desactivadas. Puedes seguir usando Tab.');
            save();
        }
    });
    const focusables = 'a[href], button, input:not([type="hidden"]), select, textarea, summary, [tabindex="0"]';
    const nativeArrows = 'input, textarea, select, [contenteditable]:not([contenteditable="false"]), [role="textbox"], [role="slider"], [role="spinbutton"], [role="tablist"], [role="menu"], [role="listbox"], [role="tree"], [role="grid"], [role="region"][tabindex]';
    document.addEventListener('keydown', event => {
        if (event.key === 'Escape') { if (reading) stop('Lectura detenida.'); return; }
        if (!arrows || event.defaultPrevented || event.altKey || event.ctrlKey || event.metaKey || event.shiftKey
            || !['ArrowDown', 'ArrowRight', 'ArrowUp', 'ArrowLeft'].includes(event.key)
            || event.target.closest(nativeArrows)) return;
        const scope = modal() || document;
        const controls = all(focusables, scope).filter(node => visible(node) && !node.disabled && node.tabIndex >= 0);
        if (!controls.length) return;
        const current = controls.indexOf(document.activeElement);
        const forward = event.key === 'ArrowDown' || event.key === 'ArrowRight';
        const index = current < 0 ? (forward ? 0 : controls.length - 1) : current + (forward ? 1 : -1);
        if (index < 0 || index >= controls.length) return;
        event.preventDefault();
        controls[index].focus();
    });
    document.addEventListener('focusin', event => {
        const node = event.target;
        if (!readFocus || !supported || !node.matches(focusables)
            || node.matches('[data-read-page], [data-read-stop], [data-read-pause]')) return;
        const exactLabel = node.getAttribute('data-speech-label');
        const label = exactLabel || node.getAttribute('aria-label')
            || (node.labels ? [...node.labels].map(item => item.textContent.trim()).join('. ') : '')
            || node.textContent.trim() || node.title;
        if (!label) return;
        if (exactLabel) { speak(exactLabel, false); return; }
        const type = node.matches('input, textarea, select') ? 'Campo. '
            : node.matches('a') ? 'Enlace. ' : 'Control. ';
        // Solo nombre y estado, incluso si el usuario mostró su contraseña.
        const state = node.hasAttribute('aria-pressed') ? (node.getAttribute('aria-pressed') === 'true' ? '. Activado' : '. Desactivado') : '';
        speak(type + label + state, false);
    });
    document.addEventListener('close', event => { if (event.target.matches('dialog')) stop(); }, true);
    document.addEventListener('hidden.bs.modal', () => stop());
    window.addEventListener('pagehide', () => stop());
})();
