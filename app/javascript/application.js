// Entry point served via importmap-rails. Configure the map in config/importmap.rb.

// Vanilla replacement for jquery_ujs's data-confirm support.
// Any <form data-confirm="..."> will prompt before submitting.
document.addEventListener('submit', function (event) {
  var message = event.target && event.target.dataset && event.target.dataset.confirm;
  if (message && !window.confirm(message)) {
    event.preventDefault();
  }
});

// Timeline initializer (candidates#timeline view).
// Lives here rather than in an inline <script> so the page can run under
// `script-src 'self'` with no `'unsafe-inline'` allowance. The vis-timeline
// UMD bundle is loaded from the view's content_for(:for_head) block via
// javascript_include_tag and exposes the global `vis` object.
function initCandidateTimeline() {
  var container = document.getElementById('my-timeline');
  if (!container) return;

  container.style.height = container.dataset.height + 'px';
  var eventsUrl = container.dataset.eventsUrl;

  fetch(eventsUrl, { credentials: 'same-origin' })
    .then(function (response) { return response.json(); })
    .then(function (payload) {
      var rawEvents = (payload && payload.events) || [];
      var items = rawEvents.map(function (e, idx) {
        return {
          id: idx + 1,
          content: e.title,
          start: e.start,
          end: e.end,
          type: 'range'
        };
      });

      var options = {
        stack: true,
        margin: { item: 4 },
        orientation: 'top',
        zoomMin: 1000 * 60 * 60 * 24 * 30,         // ~1 month
        zoomMax: 1000 * 60 * 60 * 24 * 365 * 50    // ~50 years
      };

      // Pick an initial window span based on the loaded items so the first
      // render isn't zoomed all the way out.
      if (items.length > 0) {
        var starts = items.map(function (i) { return new Date(i.start).getTime(); });
        var ends   = items.map(function (i) { return new Date(i.end).getTime();   });
        var minStart = new Date(Math.min.apply(null, starts));
        var maxEnd   = new Date(Math.max.apply(null, ends));
        var pad = (maxEnd - minStart) * 0.05 || (1000 * 60 * 60 * 24 * 30);
        options.start = new Date(minStart.getTime() - pad);
        options.end   = new Date(maxEnd.getTime() + pad);
      }

      new vis.Timeline(container, items, options);
    })
    .catch(function (err) {
      container.textContent = 'Failed to load timeline: ' + err;
    });
}

// Dark-mode toggle. Pico CSS 2 renders the entire UI in dark mode when
// <html data-theme="dark">. The server reads a "theme" cookie to render
// the initial page with the right attribute (no flash). This handler flips
// the attribute, updates the cookie, and swaps the toggle label.
function initThemeToggle() {
  var toggle = document.getElementById("theme-toggle");
  if (!toggle) return;

  toggle.addEventListener("click", function (e) {
    e.preventDefault();
    var html = document.documentElement;
    var current = html.getAttribute("data-theme") || "light";
    var next = current === "dark" ? "light" : "dark";

    html.setAttribute("data-theme", next);
    document.cookie = "theme=" + next + "; path=/; max-age=31536000; SameSite=Lax";
    toggle.textContent = next === "dark" ? "Light mode" : "Dark mode";
  });
}

// Status-change notes: show the "Reason for status change" textarea when
// the status dropdown changes from its original value, hide it when it's
// set back. Gated on the presence of the wrapper div so it's a no-op on
// every page except the candidate edit form.
function initStatusChangeNotes() {
  var wrapper = document.getElementById("status-change-notes-wrapper");
  if (!wrapper) return;

  var select = document.querySelector("select[data-original-status]");
  if (!select) return;

  var original = select.getAttribute("data-original-status");

  select.addEventListener("change", function () {
    wrapper.style.display = select.value !== original ? "" : "none";
  });
}

if (document.readyState === "loading") {
  document.addEventListener("DOMContentLoaded", function () {
    initCandidateTimeline();
    initThemeToggle();
    initStatusChangeNotes();
  });
} else {
  initCandidateTimeline();
  initThemeToggle();
  initStatusChangeNotes();
}
