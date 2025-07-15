// LiveToast JavaScript Hook
// Handles animations and positioning for server-rendered toasts

export default {
  mounted() {
    this.toasts = new Map();
    this.position = this.el.dataset.position || "bottom-right";
    this.gap = 15;
    this.maxToasts = parseInt(this.el.dataset.maxToasts) || null;
    this.expanded = false;

    // Handle clear-flash events from server
    this.handleEvent("clear-flash", ({ key }) => {
      const flashEl = document.querySelector(`[data-phx-flash="${key}"]`);
      if (flashEl) {
        flashEl.remove();
      }
    });

    // Set up flash message close buttons
    this.setupFlashMessageHandlers();

    this.el.addEventListener("mouseenter", () => {
      this.expanded = true;
      this.updateToasts();
    });

    this.el.addEventListener("mouseleave", () => {
      this.expanded = false;
      this.updateToasts();

      // Ensure all toasts restart their timers when container is left
      this.toasts.forEach((toastInfo, domId) => {
        const toastEl = toastInfo.element;
        const duration = parseInt(toastEl.dataset.duration || "6000");

        // Only restart timer if it's not already running and duration is valid
        if (!toastInfo.timer && duration > 0 && toastEl.getAttribute('data-removed') !== 'true') {
          toastInfo.timer = setTimeout(() => {
            this.removeToastFromServer(toastInfo.toastId);
          }, duration);
        }
      });
    });

    // Process initial toasts
    this.processToasts();
  },

  updated() {
    // Update maxToasts in case it changed
    this.maxToasts = parseInt(this.el.dataset.maxToasts) || null;

    // Immediately update positions for all toasts when DOM changes
    const toastElements = Array.from(this.el.querySelectorAll('[id^="toasts-"]'));
    toastElements.forEach((el, index) => {
      const toastEl = el.querySelector('.toast:not(.toast-flash)');
      if (!toastEl) return;

      // Update z-index immediately to ensure proper stacking
      const totalToasts = toastElements.length;
      toastEl.style.setProperty('--z-index', totalToasts - index);
    });

    // When stream updates, reprocess toasts
    this.processToasts();

    // Re-setup flash message handlers in case new ones were added
    this.setupFlashMessageHandlers();
  },

  destroyed() {
    this.toasts.clear();
  },

  processToasts() {
    const toastElements = Array.from(this.el.querySelectorAll('[id^="toasts-"]'));
    const currentIds = new Set(toastElements.map(el => el.id));

    // Remove toasts that are no longer in DOM
    for (const [id, toast] of this.toasts) {
      if (!currentIds.has(id)) {
        this.removeToast(id);
      }
    }

    // First update all existing toasts' positions immediately
    this.updateToasts();

    // Then add new toasts and ensure existing toasts maintain their mounted state
    toastElements.forEach((el, index) => {
      if (!this.toasts.has(el.id)) {
        this.addToast(el, index);
      } else {
        // Ensure existing toasts maintain their mounted state
        const toastEl = el.querySelector('.toast:not(.toast-flash)');
        if (toastEl && toastEl.getAttribute('data-mounted') !== 'true') {
          toastEl.setAttribute('data-mounted', 'true');
        }
      }
    });

    // Apply visibility limiting if maxToasts is set
    if (this.maxToasts !== null) {
      this.applyToastLimit();
    }
  },

  addToast(el, index) {
    const toastEl = el.querySelector('.toast:not(.toast-flash)');
    if (!toastEl) return;

    // Enable pointer events for the toast
    toastEl.style.pointerEvents = "auto";

    // Get toast data
    const duration = parseInt(toastEl.dataset.duration || "6000");
    const toastId = toastEl.dataset.toastId;

    // Store toast info with estimated height
    const toastInfo = {
      element: toastEl,
      height: 80, // Default estimated height
      timer: null,
      domId: el.id,
      toastId: toastId
    };

    this.toasts.set(el.id, toastInfo);

    // Get current toast count for initial positioning
    const toastElements = Array.from(this.el.querySelectorAll('[id^="toasts-"]'));
    const totalToasts = toastElements.length;
    const actualIndex = toastElements.indexOf(el);

    // Set initial CSS variables for correct stacking
    toastEl.style.setProperty('--index', actualIndex);
    toastEl.style.setProperty('--toasts-before', actualIndex);
    toastEl.style.setProperty('--z-index', totalToasts - actualIndex);
    toastEl.setAttribute('data-front', actualIndex === 0 ? 'true' : 'false');
    toastEl.setAttribute('data-expanded', this.expanded ? 'true' : 'false');

    // Initial state
    toastEl.setAttribute('data-mounted', 'false');

    // Disable transitions initially to prevent unwanted animations
    toastEl.style.transition = "none";

    // Get actual height first, then update positions
    requestAnimationFrame(() => {
      // Measure actual height before any transforms/scaling are applied
      // We need to temporarily reset transforms to get the natural height
      const originalTransform = toastEl.style.transform;
      toastEl.style.transform = 'none';
      const actualHeight = toastEl.getBoundingClientRect().height;
      toastEl.style.transform = originalTransform;

      toastInfo.height = actualHeight;
      // This is needed to make animaiton look good when we have multiple toasts of different heights collapsed and we
      // add more.
      toastEl.style.height = actualHeight + 'px';

      // Update all positions
      this.updateToasts();

      // Small delay to ensure layout is settled, then enable transitions and mount
      setTimeout(() => {
        toastEl.style.transition = "all 400ms cubic-bezier(0.21, 1.02, 0.73, 1)";
        toastEl.setAttribute('data-mounted', 'true');
      }, 10);

      // Set up auto-removal timer
      if (duration > 0 && (this.maxToasts === null || index < this.maxToasts)) {
        toastInfo.timer = setTimeout(() => {
          this.removeToastFromServer(toastId);
        }, duration);
      }
    });

    // Handle interactions
    this.setupToastInteractions(el.id, toastEl, toastInfo);
  },

  updateToasts() {
    const toastElements = Array.from(this.el.querySelectorAll('[id^="toasts-"]'));
    const totalToasts = toastElements.length;

    // Set the front toast height for stacked toast clipping
    if (toastElements.length > 0) {
      const frontToastInfo = this.toasts.get(toastElements[0].id);
      if (frontToastInfo) {
        this.el.style.setProperty('--front-toast-height', `${frontToastInfo.height}px`);
      }
    }

    // Use requestAnimationFrame to batch DOM updates
    requestAnimationFrame(() => {
      toastElements.forEach((el, index) => {
        const toastEl = el.querySelector('.toast:not(.toast-flash)');
        if (!toastEl) return;

        const toastInfo = this.toasts.get(el.id);
        if (!toastInfo) return;

        // Calculate stacking variables
        const isFront = index === 0;
        const toastsBeforeCount = index;
        const zIndex = totalToasts - index;

        // Update CSS variables
        toastEl.style.setProperty('--index', index);
        toastEl.style.setProperty('--toasts-before', toastsBeforeCount);
        toastEl.style.setProperty('--z-index', zIndex);
        toastEl.setAttribute('data-front', isFront ? 'true' : 'false');
        toastEl.setAttribute('data-expanded', this.expanded ? 'true' : 'false');

        // Calculate offset for expanded view
        if (this.expanded) {
          let offset = 0;
          for (let i = 0; i < index; i++) {
            const prevInfo = this.toasts.get(toastElements[i].id);
            if (prevInfo) {
              offset += prevInfo.height + this.gap;
            }
          }
          toastEl.style.setProperty('--offset', `${offset}px`);
        }
      });
    });
  },

  setupToastInteractions(domId, toastEl, toastInfo) {
    // Store original duration
    const originalDuration = parseInt(toastEl.dataset.duration || "6000");

    // Pause timer on hover
    toastEl.addEventListener("mouseenter", () => {
      if (toastInfo.timer) {
        clearTimeout(toastInfo.timer);
        toastInfo.timer = null;
      }
    });

    // Resume timer on mouse leave
    toastEl.addEventListener("mouseleave", () => {
      // Don't restart timer if toast is being removed or duration is infinite
      if (toastEl.getAttribute('data-removed') === 'true' || originalDuration <= 0) {
        return;
      }

      // Always restart timer when mouse leaves
      if (toastInfo.timer) {
        clearTimeout(toastInfo.timer);
      }

      toastInfo.timer = setTimeout(() => {
        this.removeToastFromServer(toastInfo.toastId);
      }, 2000); // Shorter duration after interaction
    });


    // Handle close button
    const closeBtn = toastEl.querySelector('[data-close-toast]');
    if (closeBtn) {
      closeBtn.addEventListener('click', (e) => {
        e.preventDefault();
        e.stopPropagation();

        // Clear any active timer
        if (toastInfo.timer) {
          clearTimeout(toastInfo.timer);
          toastInfo.timer = null;
        }

        const toastId = toastEl.dataset.toastId;
        this.removeToastFromServer(toastId);
      });
    }

    // Handle action button
    const actionBtn = toastEl.querySelector('[data-toast-action]');
    if (actionBtn) {
      actionBtn.addEventListener('click', () => {
        const toastId = toastEl.dataset.toastId;
        this.pushEventTo(this.el, "action", {
          toast_id: toastId,
          action: actionBtn.dataset.toastAction
        });
      });
    }
  },

  removeToast(domId) {
    const toastInfo = this.toasts.get(domId);
    if (!toastInfo) return;

    // Clear timer
    if (toastInfo.timer) {
      clearTimeout(toastInfo.timer);
    }

    // Animate out
    const isTop = this.position.includes("top");
    toastInfo.element.style.setProperty('--y', `translateY(${isTop ? "-100%" : "100%"})`);
    toastInfo.element.style.opacity = "0";
    toastInfo.element.setAttribute('data-removed', 'true');

    // Remove from tracking
    this.toasts.delete(domId);

    // Update heights and positions, maintaining expanded state if mouse is still hovering
    setTimeout(() => {
      // Check if mouse is still within container bounds
      const rect = this.el.getBoundingClientRect();
      const mouseX = this.lastMouseX || 0;
      const mouseY = this.lastMouseY || 0;

      const isMouseInBounds =
        mouseX >= rect.left &&
        mouseX <= rect.right &&
        mouseY >= rect.top &&
        mouseY <= rect.bottom;

      // Update toast positions after removal
      this.updateToasts();
    }, 100);
  },

  // Send event to server to remove toast from stream
  removeToastFromServer(toastId) {
    this.pushEventTo(this.el, "clear", { id: toastId });
  },

  applyToastLimit() {
    const toastElements = Array.from(this.el.querySelectorAll('[id^="toasts-"]'));

    // Apply visibility based on index (not position-dependent order)
    toastElements.forEach((el, index) => {
      const toastEl = el.querySelector('.toast:not(.toast-flash)');
      if (!toastEl) return;

      const toastInfo = this.toasts.get(el.id);
      if (!toastInfo) return;

      if (index >= this.maxToasts) {
        // Hide toasts beyond limit
        toastEl.style.opacity = "0";
        toastEl.style.pointerEvents = "none";
        toastEl.classList.remove('pointer-events-auto');

        // Schedule automatic removal if not already scheduled
        if (!toastInfo.removalScheduled) {
          toastInfo.removalScheduled = true;
          const toastId = toastEl.dataset.toastId;

          // Wait for animation to complete before removing
          setTimeout(() => {
            this.removeToastFromServer(toastId);
          }, 300); // Animation duration
        }
      } else {
        // Show toasts within limit
        toastEl.style.opacity = "1";
        toastEl.style.pointerEvents = "auto";
        toastEl.classList.add('pointer-events-auto');
        toastInfo.removalScheduled = false;
      }
    });
  },

  setupFlashMessageHandlers() {
    // Find the parent container that holds flash messages
    const container = this.el.parentElement;
    if (!container) return;

    // Set up delegation for flash message close buttons
    container.addEventListener('click', (e) => {
      if (e.target.matches('[data-close-flash]')) {
        e.preventDefault();
        e.stopPropagation();

        const flashKey = e.target.dataset.flashKey;
        const flashType = e.target.dataset.flashType;
        const flashToast = e.target.closest('.toast-flash');

        if (flashToast) {
          // Animate out
          flashToast.style.opacity = '0';
          flashToast.style.transform = 'translateX(100%)';

          // Remove after animation and notify server
          setTimeout(() => {
            flashToast.remove();
            // Send event to server to clear flash from state
            this.pushEventTo(this.el, "clear-flash", { key: flashKey, type: flashType });

            // Also send event to parent LiveView to clear from Phoenix flash
            this.pushEvent("lv:clear-flash", { key: flashKey });
          }, 300);
        }
      }
    });
  }
};
