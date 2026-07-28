/* ==========================================================================
   Uni-Run front end behaviour
   --------------------------------------------------------------------------
   Loaded from the <head> of every page. Plain browser JavaScript, no library
   and nothing downloaded from the internet, so the system behaves the same
   with the network switched off.

   Three things live here:
     1. Dark and light theme, remembered between pages.
     2. A command palette opened with Ctrl+K.
     3. Instant filtering for long tables and card grids.

   The theme is applied straight away, before the browser paints, so the page
   never flashes the wrong colours. Everything else waits for the document.
   ========================================================================== */
(function () {
    "use strict";

    var STORAGE_KEY = "unirun-theme";

    /* ======================================================================
       1. Theme
       ====================================================================== */

    function storedTheme() {
        try {
            return window.localStorage.getItem(STORAGE_KEY);
        } catch (e) {
            // Private browsing can block storage. The site still works,
            // the choice just is not remembered.
            return null;
        }
    }

    function saveTheme(value) {
        try {
            window.localStorage.setItem(STORAGE_KEY, value);
        } catch (e) {
            /* ignore */
        }
    }

    function systemPrefersDark() {
        return window.matchMedia
            && window.matchMedia("(prefers-color-scheme: dark)").matches;
    }

    function applyTheme(theme) {
        document.documentElement.setAttribute("data-theme", theme);
    }

    function currentTheme() {
        return document.documentElement.getAttribute("data-theme") === "dark"
            ? "dark"
            : "light";
    }

    function toggleTheme() {
        var next = currentTheme() === "dark" ? "light" : "dark";
        applyTheme(next);
        saveTheme(next);
        updateToggleButton();
    }

    // Runs immediately: saved choice first, otherwise follow the operating
    // system setting.
    applyTheme(storedTheme() || (systemPrefersDark() ? "dark" : "light"));

    function updateToggleButton() {
        var button = document.querySelector(".theme-toggle");
        if (!button) {
            return;
        }

        var dark = currentTheme() === "dark";
        button.textContent = dark ? "☀" : "☽";
        button.setAttribute("aria-label",
            dark ? "Switch to light theme" : "Switch to dark theme");
        button.setAttribute("title",
            dark ? "Switch to light theme" : "Switch to dark theme");
    }

    function addThemeToggle() {
        // The button is added by script rather than written into all twelve
        // pages, so the navigation markup stays untouched.
        var host = document.querySelector(".navbar .nav-links")
                || document.querySelector(".navbar > div:last-child")
                || document.querySelector("header nav");

        if (!host || host.querySelector(".theme-toggle")) {
            return;
        }

        var button = document.createElement("button");
        button.type = "button";
        button.className = "theme-toggle";
        button.addEventListener("click", toggleTheme);
        host.appendChild(button);

        updateToggleButton();
    }

    /* ======================================================================
       2. Command palette
       ====================================================================== */

    /**
     * Works out what the visitor may do from the links the server rendered.
     * The admin navigation is the only place that links to adminDashboard.jsp,
     * and a logout link only appears once somebody is signed in.
     */
    function detectRole() {
        if (document.querySelector('a[href="adminDashboard.jsp"]')) {
            return "admin";
        }
        if (document.querySelector('a[href="LogoutServlet"]')) {
            return "participant";
        }
        return "guest";
    }

    function buildCommands(role) {
        var commands = [
            { group: "Navigate", icon: "🏠", label: "Home", href: "index.jsp" },
            { group: "Navigate", icon: "🏃", label: "Browse Events", href: "events.jsp" },
            { group: "Navigate", icon: "🏆", label: "Leaderboard", href: "leaderboard.jsp" }
        ];

        if (role === "guest") {
            commands.push({ group: "Account", icon: "🔐", label: "Log In", href: "login.jsp" });
            commands.push({ group: "Account", icon: "📝", label: "Create an Account", href: "register.jsp" });
        }

        if (role === "participant") {
            commands.push({ group: "Navigate", icon: "📊", label: "My Dashboard", href: "dashboard.jsp" });
            commands.push({ group: "Actions", icon: "⏱", label: "Submit a Race Result", href: "submitResult.jsp" });
            commands.push({ group: "Actions", icon: "✅", label: "My Result Status", href: "viewResultStatus.jsp" });
            commands.push({ group: "Account", icon: "🚪", label: "Log Out", href: "LogoutServlet" });
        }

        if (role === "admin") {
            commands.push({ group: "Navigate", icon: "📊", label: "Admin Dashboard", href: "adminDashboard.jsp" });
            commands.push({ group: "Manage", icon: "📅", label: "Manage Events", href: "manageEvents.jsp" });
            commands.push({ group: "Manage", icon: "➕", label: "Add a New Event", href: "addEvent.jsp" });
            commands.push({ group: "Manage", icon: "👥", label: "Manage Participants", href: "manageParticipants.jsp" });
            commands.push({ group: "Manage", icon: "✔", label: "Approve Results", href: "approveResults.jsp" });
            commands.push({ group: "Account", icon: "🚪", label: "Log Out", href: "LogoutServlet" });
        }

        commands.push({
            group: "Settings",
            icon: "🌓",
            label: "Toggle dark mode",
            action: toggleTheme
        });

        return commands;
    }

    function createPalette(commands) {
        var backdrop = document.createElement("div");
        backdrop.className = "cmdk-backdrop";
        backdrop.hidden = true;

        backdrop.innerHTML =
              '<div class="cmdk-panel" role="dialog" aria-modal="true" aria-label="Command palette">'
            + '<input class="cmdk-input" type="text" autocomplete="off" spellcheck="false"'
            + ' placeholder="Search pages and actions...">'
            + '<ul class="cmdk-list"></ul>'
            + '<div class="cmdk-footer">'
            + '<span><kbd>&uarr;</kbd> <kbd>&darr;</kbd> move</span>'
            + '<span><kbd>Enter</kbd> open</span>'
            + '<span><kbd>Esc</kbd> close</span>'
            + '</div>'
            + '</div>';

        document.body.appendChild(backdrop);

        var input = backdrop.querySelector(".cmdk-input");
        var list = backdrop.querySelector(".cmdk-list");
        var matches = [];
        var selected = 0;

        function run(command) {
            close();
            if (command.action) {
                command.action();
            } else {
                window.location.href = command.href;
            }
        }

        function render(query) {
            var needle = query.trim().toLowerCase();

            matches = commands.filter(function (command) {
                return needle === ""
                    || command.label.toLowerCase().indexOf(needle) !== -1
                    || command.group.toLowerCase().indexOf(needle) !== -1;
            });

            selected = 0;
            list.innerHTML = "";

            if (matches.length === 0) {
                var empty = document.createElement("li");
                empty.className = "cmdk-empty";
                empty.textContent = 'Nothing matches "' + query + '"';
                list.appendChild(empty);
                return;
            }

            var lastGroup = null;

            matches.forEach(function (command, index) {
                if (command.group !== lastGroup) {
                    lastGroup = command.group;
                    var heading = document.createElement("li");
                    heading.className = "cmdk-group";
                    heading.textContent = command.group;
                    list.appendChild(heading);
                }

                var item = document.createElement("li");
                item.className = "cmdk-item";
                item.setAttribute("role", "option");
                item.setAttribute("aria-selected", index === selected ? "true" : "false");
                item.dataset.index = index;

                item.innerHTML =
                      '<span class="cmdk-icon"></span>'
                    + '<span class="cmdk-text"></span>'
                    + '<span class="cmdk-hint"></span>';

                item.querySelector(".cmdk-icon").textContent = command.icon;
                item.querySelector(".cmdk-text").textContent = command.label;
                item.querySelector(".cmdk-hint").textContent =
                    command.action ? "action" : command.href;

                item.addEventListener("click", function () {
                    run(command);
                });

                item.addEventListener("mousemove", function () {
                    highlight(index);
                });

                list.appendChild(item);
            });
        }

        function highlight(index) {
            selected = index;
            var items = list.querySelectorAll(".cmdk-item");
            Array.prototype.forEach.call(items, function (item) {
                var isSelected = Number(item.dataset.index) === selected;
                item.setAttribute("aria-selected", isSelected ? "true" : "false");
                if (isSelected && item.scrollIntoView) {
                    item.scrollIntoView({ block: "nearest" });
                }
            });
        }

        function move(step) {
            if (matches.length === 0) {
                return;
            }
            var next = (selected + step + matches.length) % matches.length;
            highlight(next);
        }

        function open() {
            backdrop.hidden = false;
            input.value = "";
            render("");
            input.focus();
        }

        function close() {
            backdrop.hidden = true;
        }

        function isOpen() {
            return !backdrop.hidden;
        }

        input.addEventListener("input", function () {
            render(input.value);
        });

        backdrop.addEventListener("mousedown", function (event) {
            if (event.target === backdrop) {
                close();
            }
        });

        document.addEventListener("keydown", function (event) {
            var key = event.key ? event.key.toLowerCase() : "";

            if ((event.ctrlKey || event.metaKey) && key === "k") {
                event.preventDefault();
                if (isOpen()) {
                    close();
                } else {
                    open();
                }
                return;
            }

            if (!isOpen()) {
                return;
            }

            if (event.key === "Escape") {
                event.preventDefault();
                close();
            } else if (event.key === "ArrowDown") {
                event.preventDefault();
                move(1);
            } else if (event.key === "ArrowUp") {
                event.preventDefault();
                move(-1);
            } else if (event.key === "Enter") {
                event.preventDefault();
                if (matches[selected]) {
                    run(matches[selected]);
                }
            }
        });
    }

    /* ======================================================================
       3. Instant filtering

       Any input carrying data-filter="<css selector>" hides or shows the
       elements matching that selector as the visitor types. It runs entirely
       in the browser on rows the server already sent, so there is no extra
       request and it works offline.
       ====================================================================== */
    function setUpFilters() {
        var inputs = document.querySelectorAll("[data-filter]");

        Array.prototype.forEach.call(inputs, function (input) {
            var targets = document.querySelectorAll(input.getAttribute("data-filter"));
            var counter = input.parentNode.querySelector(".filter-count");

            function apply() {
                var needle = input.value.trim().toLowerCase();
                var shown = 0;

                Array.prototype.forEach.call(targets, function (target) {
                    var hit = needle === ""
                        || target.textContent.toLowerCase().indexOf(needle) !== -1;
                    target.style.display = hit ? "" : "none";
                    if (hit) {
                        shown++;
                    }
                });

                if (counter) {
                    counter.textContent = needle === ""
                        ? ""
                        : shown + " of " + targets.length + " shown";
                }
            }

            input.addEventListener("input", apply);
        });
    }

    /* ======================================================================
       Start up
       ====================================================================== */
    function init() {
        addThemeToggle();
        createPalette(buildCommands(detectRole()));
        setUpFilters();
    }

    if (document.readyState === "loading") {
        document.addEventListener("DOMContentLoaded", init);
    } else {
        init();
    }
}());
