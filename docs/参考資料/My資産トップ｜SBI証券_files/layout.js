var _a, _b;
var slcCommon = slcCommon || {};
slcCommon.body = document.body;
slcCommon.responsiveWindowSize = 769;
slcCommon.screenMdQuery = window.matchMedia("(min-width: 769px)");
slcCommon.globalHamburger = document.querySelector("[data-global-hamburger]");
slcCommon.globalNav = document.querySelector(".slc-global-nav");
slcCommon.dotsMenuButton = document.querySelector('[data-dots-menu="slide"]');
slcCommon.dotsMenuTrigger = document.querySelector(
  '[data-dots-menu="trigger"]'
);
slcCommon.localLinkNav = document.querySelector(".slc-local-link-nav");
slcCommon.removeElement = (element) => {
  if (element) {
    element.parentNode.removeChild(element);
  }
};
slcCommon.isResponsive = () => {
  return !!(document.querySelector("head meta[name=viewport]") && !document.querySelector("[data-non-responsive-page]"));
};
slcCommon.isMobileDevice = () => {
  const userAgent = window.navigator.userAgent || "";
  const maxTouchPoints = window.navigator.maxTouchPoints || 0;
  return /iPhone|iPad|iPod/.test(userAgent) || /Macintosh/.test(userAgent) && maxTouchPoints > 1 || /Android/.test(userAgent);
};
slcCommon.closeHamburgerMenu = () => {
  var _a2;
  const isOpen = slcCommon.globalHamburger.getAttribute("aria-expanded") === "true";
  if (isOpen) {
    (_a2 = slcCommon.globalNav) == null ? void 0 : _a2.setAttribute("aria-expanded", !isOpen);
    slcCommon.globalHamburger.checked = !isOpen;
    slcCommon.globalHamburger.setAttribute("aria-expanded", !isOpen);
  }
};
slcCommon.closeHeaderDropdownContent = () => {
  const openDropdowns = document.querySelectorAll(
    '[data-nav-item][aria-expanded="true"]'
  );
  openDropdowns == null ? void 0 : openDropdowns.forEach((openDropdown) => {
    openDropdown.setAttribute("aria-expanded", false);
  });
};
slcCommon.closeDotsMenu = () => {
  slcCommon.dotsMenuTrigger.querySelector("input").checked = false;
  slcCommon.dotsMenuTrigger.querySelector("input").setAttribute("aria-expanded", false);
  slcCommon.dotsMenuButton.setAttribute("aria-expanded", false);
};
slcCommon.closeSearchDropdown = () => {
  if (document.querySelector('[data-search="trigger"]').hasAttribute("aria-expanded")) {
    document.querySelector('[data-search="trigger"]').setAttribute("aria-expanded", false);
  }
};
slcCommon.toggleDropdown = (dropdownTriggerButton) => {
  const isExpanded = (dropdownTriggerButton == null ? void 0 : dropdownTriggerButton.getAttribute("aria-expanded")) === "true";
  dropdownTriggerButton.querySelector("input").checked = !isExpanded;
  dropdownTriggerButton.setAttribute("aria-expanded", !isExpanded);
  const localLinkNav = document.querySelector(".slc-local-link-nav");
  if (!isExpanded) {
    slcCommon.showOverlay();
    if (localLinkNav) {
      localLinkNav.style.zIndex = "110";
    }
    dropdownTriggerButton.closest(".slc-local-side-nav").style.zIndex = "110";
    slcCommon.body.addEventListener("click", slcCommon.triggerDropdown);
  } else {
    slcCommon.hideOverlay();
    if (localLinkNav) {
      localLinkNav.style.zIndex = "";
    }
    dropdownTriggerButton.closest(".slc-local-side-nav").style.zIndex = "";
    slcCommon.body.removeEventListener("click", slcCommon.triggerDropdown);
  }
};
slcCommon.triggerDropdown = (e) => {
  var _a2, _b2, _c;
  if (e.target.closest(
    "[data-local-side-nav-menu] .slc-nav-title-item .slc-nav-title"
  )) {
    return;
  }
  if (!e.target.closest(
    "[data-local-side-nav-menu] .slc-nav-accordion-item .slc-nav-header"
  ) && !((_a2 = e.target.classList) == null ? void 0 : _a2.contains("slc-header-nav")) && !((_b2 = e.target.classList) == null ? void 0 : _b2.contains("slc-header-nav-container"))) {
    slcCommon.toggleDropdown(
      document.querySelector("[data-local-side-nav-trigger]")
    );
    if (!((_c = e.target.classList) == null ? void 0 : _c.contains("slc-overlay")) && e.target.closest(".slc-header")) {
      slcCommon.showOverlay();
    }
  }
};
slcCommon.getMemberCategory = () => {
  const currentSystem = slcCommon.getSystem();
  if (currentSystem === "member") {
    let category = window.location.pathname.split("/")[1].toUpperCase().replace(/-/g, "_");
    if (category === "contents") {
      category = window.location.pathname.split("/")[2].toUpperCase().replace(/-/g, "_");
    }
    return category;
  }
  return false;
};
slcCommon.layoutScrollLocation = 0;
slcCommon.hideOverlay = () => {
  const overlay = document.querySelector("[data-overlay]");
  if (!overlay)
    return;
  slcCommon.removeElement(overlay);
  slcCommon.body.classList.remove("slc-nav-unscroll");
  slcCommon.body.style.removeProperty("top");
  window.scrollTo({
    top: slcCommon.layoutScrollLocation,
    behavior: "instant"
  });
  document.querySelector("html").classList.remove("slc-unscroll");
};
slcCommon.showOverlay = () => {
  var _a2, _b2;
  document.querySelector("html").classList.add("slc-unscroll");
  slcCommon.layoutScrollLocation = window.scrollY;
  slcCommon.body.classList.add("slc-nav-unscroll");
  slcCommon.body.style.top = `-${slcCommon.layoutScrollLocation}px`;
  const overlay = '<div class="slc-overlay" data-overlay data-design="seeds-layout"></div>';
  (_a2 = document.querySelector("[data-overlay]")) != null ? _a2 : slcCommon.body.insertAdjacentHTML("beforeend", overlay);
  (_b2 = document.querySelector("[data-overlay]")) == null ? void 0 : _b2.addEventListener("click", () => {
    slcCommon.hideOverlay();
    slcCommon.closeHamburgerMenu();
    slcCommon.closeDotsMenu();
  });
};
slcCommon.hideModalOverlay = () => {
  const overlay = document.querySelector("[data-modal-overlay]");
  if (!overlay)
    return;
  slcCommon.removeElement(overlay);
  slcCommon.body.classList.remove("slc-nav-unscroll");
  slcCommon.body.style.removeProperty("top");
  window.scrollTo({
    top: slcCommon.layoutScrollLocation,
    behavior: "instant"
  });
  document.querySelector("html").classList.remove("slc-unscroll");
};
slcCommon.showModalOverlay = () => {
  var _a2;
  document.querySelector("html").classList.add("slc-unscroll");
  slcCommon.layoutScrollLocation = window.scrollY;
  slcCommon.body.classList.add("slc-nav-unscroll");
  slcCommon.body.style.top = `-${slcCommon.layoutScrollLocation}px`;
  const overlay = '<div class="slc-modal-overlay" data-modal-overlay  data-design="seeds-layout"></div>';
  (_a2 = document.querySelector("[data-modal-overlay]")) != null ? _a2 : slcCommon.body.insertAdjacentHTML("beforeend", overlay);
};
slcCommon.clearEventListener = () => {
  var _a2;
  (_a2 = slcCommon.globalNav) == null ? void 0 : _a2.removeAttribute("aria-expanded");
  slcCommon.closeDotsMenu();
  slcCommon.closeHamburgerMenu();
  slcCommon.closeSearchDropdown();
  slcCommon.hideOverlay();
};
slcCommon.switchStyle = () => {
  if (slcCommon.isResponsive()) {
    document.querySelectorAll('[data-design="seeds-layout"]').forEach((dataDesign) => {
      dataDesign.setAttribute("data-design", "seeds-layout-responsive");
    });
    slcCommon.headObserver.disconnect();
  } else {
    document.querySelectorAll('[data-design="seeds-layout-responsive"]').forEach((dataDesign) => {
      dataDesign.setAttribute("data-design", "seeds-layout");
    });
  }
};
slcCommon.getCookieObject = () => {
  const cookies = document.cookie.split("; ").reduce((acc, cookie) => {
    const [key, value] = cookie.split("=");
    acc[key] = value;
    return acc;
  }, {});
  return (cookies == null ? void 0 : cookies.login_info) ? JSON.parse(decodeURIComponent(cookies.login_info)).data : false;
};
slcCommon.headObserver = new MutationObserver((mutations) => {
  mutations.forEach((mutation) => {
    slcCommon.switchStyle();
  });
});
slcCommon.headObserverConfig = {
  subtree: false,
  childList: true
};
slcCommon.IntermediaryToggleLink = () => {
  var _a2;
  const isCustomer = slcCommon.getIsLogin();
  if (isCustomer) {
    const cookieData = slcCommon.getCookieObject();
    const intermediaryCode = (_a2 = cookieData == null ? void 0 : cookieData.intermediaryProfile) == null ? void 0 : _a2.code;
    if (["1221", "1265"].includes(intermediaryCode)) {
      const intermediaryLinks = document.querySelectorAll(
        "[data-intermediary-link]"
      );
      intermediaryLinks.forEach((link) => {
        const linkType = link.getAttribute("data-intermediary-link");
        if (intermediaryCode === "1221") {
          if (linkType === "exclusive")
            link.classList.remove("slc-hide");
          if (linkType === "shop") {
            link.href = link.href.replace(
              "home_shop.html",
              "home_shop_1221.html"
            );
          }
        } else if (intermediaryCode === "1265") {
          if (linkType === "exclusive")
            link.classList.remove("slc-hide");
        }
      });
    }
  }
};
document.addEventListener("DOMContentLoaded", slcCommon.IntermediaryToggleLink);
slcCommon.toggleIntermediaryContent = (attrName, className, isHide) => {
  var _a2, _b2;
  const isCustomer = slcCommon.getIsLogin();
  if (isCustomer) {
    const cookieData = slcCommon.getCookieObject();
    const intermediaryCode = (_a2 = cookieData == null ? void 0 : cookieData.intermediaryProfile) == null ? void 0 : _a2.code;
    (_b2 = document.querySelectorAll(`[${attrName}]`)) == null ? void 0 : _b2.forEach((intermediaryContent) => {
      const dataIntermediaryCodes = intermediaryContent.getAttribute(attrName).split(",");
      dataIntermediaryCodes.forEach((dataIntermediaryCode) => {
        if (dataIntermediaryCode === intermediaryCode) {
          intermediaryContent.classList.toggle(className, isHide);
        }
      });
    });
  }
};
document.addEventListener("DOMContentLoaded", () => {
  slcCommon.toggleIntermediaryContent(
    "data-intermediary-content-hide",
    "slc-hide",
    true
  );
  slcCommon.toggleIntermediaryContent(
    "data-intermediary-content-show",
    "slc-hide",
    false
  );
});
let hasTouch = false;
document.addEventListener("touchstart", () => {
  hasTouch = true;
  return;
});
document.addEventListener("DOMContentLoaded", () => {
  const responsivePage = document.querySelector("[data-responsive-page]");
  if (responsivePage) {
    document.head.insertAdjacentHTML(
      "afterbegin",
      '<meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0" />'
    );
    const hash = window.location.hash;
    if (!hash) {
      setTimeout(() => {
        if (!hasTouch && !slcCommon.screenMdQuery.matches) {
          window.scroll(0, 0);
        }
      }, 350);
    }
  }
  if (slcCommon.isMobileDevice() && !slcCommon.isResponsive()) {
    document.body.setAttribute("data-non-responsive-page", "");
    document.head.insertAdjacentHTML(
      "afterbegin",
      '<meta name="viewport" content="width=1280" />'
    );
  }
  slcCommon.switchStyle();
  slcCommon.headObserver.observe(document.head, slcCommon.headObserverConfig);
});
slcCommon.getSystem = () => {
  const urlPathName = window.location.pathname.split("/")[1];
  if (urlPathName === "ETGate") {
    return "genesis";
  } else if (urlPathName === "marble") {
    return "marble";
  } else if (urlPathName === "midas") {
    return "midas";
  }
  const urlOrigin = window.location.origin.split("//")[1];
  if (urlOrigin.match(/^(m|tm|tm2).(sbisec.co.jp|sbisec.co.jp(:\d+))$/g)) {
    return "switchSite";
  }
  if (urlOrigin.match(
    /^(site|test1-site|test2-site|test3-site).(sbisec.co.jp|sbisec.co.jp(:\d+))$/g
  )) {
    return "aqua";
  }
  if (urlOrigin.match(/member.*.c.sbisec.co.jp$/g)) {
    return "member";
  }
};
slcCommon.getIsLogin = () => {
  if (slcCommon.getSystem() === "member")
    return true;
  return typeof IS_LOGIN !== "undefined" && IS_LOGIN;
};
slcCommon.callGetApi = async (endPoint, param) => {
  let url = endPoint;
  if (param) {
    const queryParams = new URLSearchParams(param);
    url = `${endPoint}?${queryParams.toString()}`;
  }
  const response = await fetch(url);
  return await response.json();
};
slcCommon.getUniqueStr = () => {
  const strong = 1e3;
  return new Date().getTime().toString(16) + Math.floor(strong * Math.random()).toString(16);
};
slcCommon.getLoginUrl = () => {
  if (MAIN_SITE_URL.match(/^https:\/\/www\.t-perf\.sbisec\.co\.jp$/)) {
    return ["https://perf-login", "sbisec", "co", "jp"].join(".");
  } else if (MAIN_SITE_URL.match(/^https:\/\/www\.t-uat[123]\.sbisec\.co\.jp$/)) {
    return ["https://curr-login", "sbisec", "co", "jp"].join(".");
  } else if (MAIN_SITE_URL.match(/^https:\/\/www\.d-int[123]\.sbisec\.co\.jp$/)) {
    return ["https://int-login", "sbisec", "co", "jp/"].join(".");
  } else {
    return null;
  }
};
slcCommon.changeTarget = (e) => {
  if (typeof MAIN_SITE_URL !== "undefined" && MAIN_SITE_URL !== "https://www.sbisec.co.jp") {
    const UAT_URLS = /* @__PURE__ */ new Map();
    UAT_URLS.set(
      "https://sbisec.akamaized.net",
      typeof AKAMAI_URL === "undefined" ? null : AKAMAI_URL
    );
    UAT_URLS.set(
      "https://faq.sbisec.co.jp",
      typeof FAQ_URL === "undefined" ? null : FAQ_URL
    );
    UAT_URLS.set(
      "https://go.sbisec.co.jp",
      typeof GO_URL === "undefined" ? null : GO_URL
    );
    UAT_URLS.set(
      "https://www.sbisec.co.jp",
      typeof MAIN_SITE_URL === "undefined" ? null : MAIN_SITE_URL
    );
    UAT_URLS.set(
      "https://sbi-themeusa.image.jp",
      typeof MINKABU_URL === "undefined" ? null : MINKABU_URL
    );
    UAT_URLS.set(
      "https://apl.wealthadvisor.jp",
      typeof WEALTH_ADVISOR_URL === "undefined" ? null : WEALTH_ADVISOR_URL
    );
    UAT_URLS.set(
      "https://graph.sbisec.co.jp",
      typeof REUTERS_URL === "undefined" ? null : REUTERS_URL
    );
    UAT_URLS.set(
      "https://sbi-fs.ifis.co.jp",
      typeof IFIS_URL === "undefined" ? null : IFIS_URL
    );
    UAT_URLS.set(
      "https://search.sbisec.co.jp",
      typeof SEARCH_URL === "undefined" ? null : SEARCH_URL
    );
    UAT_URLS.set(
      "https://member.c.sbisec.co.jp",
      typeof MEMBER_SITE_URL === "undefined" ? null : MEMBER_SITE_URL
    );
    const loginUrl = slcCommon.getLoginUrl();
    UAT_URLS.set(
      "https://login.sbisec.co.jp",
      typeof LOGIN_URL === "undefined" ? loginUrl : LOGIN_URL
    );
    const target = e.target.closest("a") || e.target;
    if (target.href) {
      let absolutePathHref = target.href;
      const targetValue = target.getAttribute("target") || slcCommon.getUniqueStr();
      const originUrl = new URL(absolutePathHref).origin;
      const baseUrl = UAT_URLS.get(originUrl);
      e.preventDefault();
      const url = baseUrl == null ? absolutePathHref : absolutePathHref.replace(originUrl, baseUrl);
      if (e.ctrlKey || targetValue === "_blank") {
        window.open(url, targetValue);
        return;
      }
      location.href = url;
    }
  }
};
slcCommon.setUatUrl = () => {
  const staticContents = document.querySelectorAll("[data-static-contents]");
  staticContents.forEach((staticContent) => {
    staticContent.removeEventListener("click", slcCommon.changeTarget);
    staticContent.addEventListener("click", slcCommon.changeTarget);
  });
};
slcCommon.getScrollBarWidth = () => {
  let userAgent = window.navigator.userAgent.toLowerCase();
  let isSmartDevice = userAgent.indexOf("iphone") != -1 || userAgent.indexOf("ipod") != -1 || userAgent.indexOf("android") != -1 || userAgent.indexOf("mobile") != -1;
  userAgent.indexOf("ipad") != -1 || userAgent.indexOf("macintosh") != -1 && "ontouchend" in document;
  document.documentElement.style.setProperty(
    "--scrollbar-width",
    `${isSmartDevice ? 0 : window.innerWidth - document.documentElement.clientWidth}px`
  );
};
window.addEventListener("load", () => {
  const responsivePage = document.querySelector("[data-responsive-page]");
  if (responsivePage) {
    slcCommon.getScrollBarWidth();
  }
});
document.addEventListener("DOMContentLoaded", () => {
  const isCustomer = slcCommon.getIsLogin();
  const targetBlocks = document.querySelectorAll("[data-static-contents]");
  targetBlocks.forEach((targetBlock) => {
    if (isCustomer) {
      targetBlock.dataset.staticContents = "customer";
    } else {
      targetBlock.dataset.staticContents = "visitor";
    }
  });
});
window.addEventListener("pagehide", () => {
  slcCommon.closeSearchDropdown();
  slcCommon.hideOverlay();
  slcCommon.closeHamburgerMenu();
  slcCommon.closeDotsMenu();
  slcCommon.closeHeaderDropdownContent();
});
var slcSideNav = slcSideNav || {};
slcSideNav.sideNavTimer;
slcSideNav.expandedLists = {
  market: true,
  domestic: true,
  foreign: true,
  fund: true,
  bond: true,
  fx: true,
  op: true,
  cx: true,
  cfd: true,
  otccfd: true,
  gold: true,
  nisa: true,
  dc: true,
  stockop: true,
  st: true,
  wrap: true,
  robot: true,
  support: true,
  fmmf: true,
  banking: true,
  service: true,
  settings: true
};
slcSideNav.setLocalDropdownNav = () => {
  var _a2, _b2, _c;
  const currentLocalSideNav = (_a2 = document.querySelector("#local-side-nav")) == null ? void 0 : _a2.nextElementSibling;
  const currentLocalDropdownNav = (_b2 = document.querySelector(
    "#local-dropdown-nav"
  )) == null ? void 0 : _b2.nextElementSibling;
  if (!(currentLocalDropdownNav == null ? void 0 : currentLocalDropdownNav.classList.contains("slc-local-side-nav")) && (currentLocalSideNav == null ? void 0 : currentLocalSideNav.classList.contains("slc-local-side-nav")) && slcCommon.isResponsive()) {
    const cloneLocalSideNav = currentLocalSideNav == null ? void 0 : currentLocalSideNav.cloneNode(true);
    document.getElementById("local-dropdown-nav").after(cloneLocalSideNav);
    slcCommon.removeElement(currentLocalSideNav);
    (_c = document.querySelector(".slc-local-side-nav > .slc-nav-container")) == null ? void 0 : _c.classList.remove("slc-hide");
    const dropdownTriggerButton = cloneLocalSideNav == null ? void 0 : cloneLocalSideNav.querySelector(
      "[data-local-side-nav-trigger]"
    );
    const accordionTriggerButton = dropdownTriggerButton == null ? void 0 : dropdownTriggerButton.nextElementSibling.querySelectorAll(
      ".slc-nav-accordion-item .slc-nav-header"
    );
    slcSideNav.handleClickDropdown(dropdownTriggerButton);
    accordionTriggerButton == null ? void 0 : accordionTriggerButton.forEach((accordionTrigger) => {
      accordionTrigger == null ? void 0 : accordionTrigger.removeEventListener(
        "click",
        slcSideNav.handleAccordion
      );
      accordionTrigger == null ? void 0 : accordionTrigger.addEventListener("click", slcSideNav.handleAccordion);
    });
    slcCommon.setUatUrl();
    slcSideNav.setSwitchPage();
  }
  return;
};
slcSideNav.setLocalSideNav = () => {
  var _a2, _b2, _c, _d;
  const currentLocalSideNav = (_a2 = document.querySelector("#local-side-nav")) == null ? void 0 : _a2.nextElementSibling;
  const currentLocalDropdownNav = (_b2 = document.querySelector(
    "#local-dropdown-nav"
  )) == null ? void 0 : _b2.nextElementSibling;
  (_c = document.querySelector(".slc-local-side-nav > .slc-nav-container")) == null ? void 0 : _c.classList.remove("slc-hide");
  if (!(currentLocalSideNav == null ? void 0 : currentLocalSideNav.classList.contains("slc-local-side-nav")) && (currentLocalDropdownNav == null ? void 0 : currentLocalDropdownNav.classList.contains("slc-local-side-nav")) && slcCommon.isResponsive()) {
    const cloneLocalDropdownNav = currentLocalDropdownNav == null ? void 0 : currentLocalDropdownNav.cloneNode(true);
    document.getElementById("local-side-nav").after(cloneLocalDropdownNav);
    slcCommon.removeElement(currentLocalDropdownNav);
    if (((_d = cloneLocalDropdownNav == null ? void 0 : cloneLocalDropdownNav.querySelector("[data-local-side-nav-trigger]")) == null ? void 0 : _d.getAttribute("aria-expanded")) === "true") {
      slcCommon.toggleDropdown(
        cloneLocalDropdownNav == null ? void 0 : cloneLocalDropdownNav.querySelector("[data-local-side-nav-trigger]")
      );
    }
  }
  const localSideNavAccordions = document.querySelectorAll(
    "[data-local-side-nav-menu] .slc-nav-accordion-item .slc-nav-header"
  );
  localSideNavAccordions == null ? void 0 : localSideNavAccordions.forEach((accordionTrigger) => {
    accordionTrigger == null ? void 0 : accordionTrigger.removeEventListener("click", slcSideNav.handleAccordion);
    accordionTrigger == null ? void 0 : accordionTrigger.addEventListener("click", slcSideNav.handleAccordion);
  });
};
slcSideNav.closeAccordion = (e) => {
  if (!e.ctrlKey) {
    const sideNavAccordionItems = document.querySelectorAll(
      "[data-local-side-nav-menu] .slc-nav-accordion-item"
    );
    sideNavAccordionItems == null ? void 0 : sideNavAccordionItems.forEach((sideNavAccordionItem) => {
      sideNavAccordionItem.querySelector("input").checked = false;
      sideNavAccordionItem.querySelector(".slc-nav-header").setAttribute("aria-expanded", false);
    });
  }
};
slcSideNav.setSwitchPage = () => {
  const sideNavItems = document.querySelectorAll(
    "[data-local-side-nav-menu] .slc-nav-item"
  );
  sideNavItems == null ? void 0 : sideNavItems.forEach((sideNavItem) => {
    const sideNavLink = sideNavItem.querySelector(".slc-nav-link");
    if (sideNavLink && sideNavLink.tagName !== "BUTTON" && sideNavLink.target !== "_blank" && sideNavLink.href && !sideNavLink.href.trim().toLowerCase().startsWith("javascript")) {
      sideNavItem == null ? void 0 : sideNavItem.removeEventListener("click", slcSideNav.closeAccordion);
      sideNavItem == null ? void 0 : sideNavItem.addEventListener("click", slcSideNav.closeAccordion);
    }
  });
};
slcSideNav.handleClickDropdown = (dropdownTriggerButton) => {
  dropdownTriggerButton == null ? void 0 : dropdownTriggerButton.addEventListener("click", (e) => {
    e.preventDefault();
    e.stopImmediatePropagation();
    slcCommon.toggleDropdown(e.currentTarget);
  });
};
slcSideNav.toggleAccordion = (item) => {
  const isExpanded = (item == null ? void 0 : item.getAttribute("aria-expanded")) === "true";
  item.querySelector("input").checked = !isExpanded;
  item.setAttribute("aria-expanded", !isExpanded);
};
slcSideNav.handleAccordion = (e) => {
  e.preventDefault();
  slcSideNav.toggleAccordion(e.currentTarget);
};
slcSideNav.setLowerRelatedMenu = () => {
  if (!slcCommon.isResponsive())
    return;
  const lowerRelatedMenu = document.querySelector("#lower-related-menu");
  if (!lowerRelatedMenu)
    return;
  lowerRelatedMenu.innerHTML = "";
  const sideMenuMiddles = document.querySelectorAll(".slc-side-menu-middle");
  const sideMenuLowers = document.querySelectorAll(".slc-side-menu-lower");
  sideMenuMiddles.forEach((menu) => {
    if (menu.closest("[data-lower-related-menu-hide]"))
      return;
    const sideMenuClone = menu.cloneNode(true);
    lowerRelatedMenu.appendChild(sideMenuClone);
  });
  sideMenuLowers.forEach((menu) => {
    if (menu.closest("[data-lower-related-menu-hide]"))
      return;
    const sideMenuClone = menu.cloneNode(true);
    lowerRelatedMenu.appendChild(sideMenuClone);
  });
};
slcSideNav.switchEventListener = () => {
  if (slcCommon.getMemberCategory() === "FOREIGN" && !slcSideNav.isSideNavDisplayed(
    '[data-uri="/seeds/common/side-menu/utf-8/foreign_side-menu_higher_contents.html"]'
  )) {
    return;
  }
  if (!slcCommon.screenMdQuery.matches && slcCommon.isResponsive()) {
    slcSideNav.setLocalDropdownNav();
  } else {
    slcCommon.clearEventListener();
    slcSideNav.setLocalSideNav();
  }
};
slcSideNav.setActivePage = () => {
  var _a2;
  const currentSystem = slcCommon.getSystem();
  let url = window.location.pathname;
  if (currentSystem === "genesis") {
    const urlParams = typeof PAGE_PARAM !== "undefined" ? new URLSearchParams(PAGE_PARAM) : new URLSearchParams(window.location.search);
    const burl = urlParams.get("burl");
    const dir = urlParams.get("dir");
    const file = urlParams.get("file");
    if (burl && dir && file) {
      url = `${burl}/${dir}/${file}`;
    }
  } else if (currentSystem === "midas" && url === "/midas/trade/spot") {
    const urlParams = new URLSearchParams(window.location.search);
    const urlParamsProduct = urlParams.get("product");
    const urlParamsType = urlParams.get("type");
    if (urlParamsProduct && urlParamsType === "2") {
      url = "/midas/trade/spot/sell";
    } else {
      url = "/midas/trade/spot/buy";
    }
  }
  if (typeof ACTIVE_SIDENAV !== "undefined") {
    url = ACTIVE_SIDENAV;
  }
  const sideNavLinks = document.querySelectorAll(
    "[data-local-side-nav-menu] .slc-nav-item"
  );
  const sideNavAccordionItems = document.querySelectorAll(
    "[data-local-side-nav-menu] .slc-nav-accordion-item"
  );
  const localSideNavTitle = document.querySelector(
    "[data-local-side-nav-title]"
  );
  let activeItem = (_a2 = document.querySelector(`[data-local-side-nav-menu] .slc-nav-item a[href="${url}"]`)) == null ? void 0 : _a2.closest(".slc-nav-item");
  sideNavLinks.forEach((sideNavLink) => {
    if (sideNavLink.getAttribute("aria-current")) {
      sideNavLink.setAttribute("aria-current", false);
    }
  });
  if (!activeItem) {
    let count = 0;
    let matchedIndex = -1;
    sideNavLinks.forEach((sideNavLink, index) => {
      var _a3, _b2;
      const linkUrl = (sideNavLink == null ? void 0 : sideNavLink.querySelector("[data-current-url]")) ? (_a3 = sideNavLink == null ? void 0 : sideNavLink.querySelector("[data-current-url]")) == null ? void 0 : _a3.getAttribute("data-current-url").split("?")[0] : (_b2 = sideNavLink == null ? void 0 : sideNavLink.querySelector("a")) == null ? void 0 : _b2.getAttribute("href").split("?")[0];
      if (url.indexOf(linkUrl) === 0 && count < linkUrl.split(/\/|\?/).length) {
        count = linkUrl.split(/\/|\?/).length;
        matchedIndex = index;
      }
    });
    if (matchedIndex > -1) {
      activeItem = sideNavLinks[matchedIndex];
    }
  }
  if (activeItem) {
    activeItem.setAttribute("aria-current", true);
    localSideNavTitle.innerHTML = activeItem == null ? void 0 : activeItem.textContent;
    sideNavAccordionItems.forEach((sideNavAccordionItem) => {
      if ((sideNavAccordionItem == null ? void 0 : sideNavAccordionItem.querySelectorAll(
        ".slc-nav-item[aria-current=true]"
      ).length) > 0) {
        const item = sideNavAccordionItem == null ? void 0 : sideNavAccordionItem.querySelector(".slc-nav-header");
        const localSideNavContent = item.nextElementSibling;
        item.querySelector("input").checked = true;
        item.setAttribute("aria-expanded", true);
        localSideNavContent == null ? void 0 : localSideNavContent.setAttribute("aria-hidden", false);
      }
    });
  }
};
slcSideNav.expandSideNavSystemHandler = () => {
  const currentSystem = slcCommon.getSystem();
  if (currentSystem === "genesis") {
    slcSideNav.expandGenesisSideNav();
  } else if (currentSystem === "marble") {
    slcSideNav.expandMarbleSideNav();
  } else if (currentSystem === "member") {
    return;
  } else if (currentSystem === "aqua") {
    return;
  } else if (currentSystem === "switchSite") {
    slcSideNav.expandSwitchSiteSideNav();
  } else if (currentSystem === "midas") {
    return;
  }
};
slcSideNav.expandGenesisSideNav = () => {
  const contentsArea01 = document.querySelector("#CONTENTSAREA01");
  const middleArea = document.querySelector("#middleArea");
  if (contentsArea01) {
    if (slcCommon.isResponsive()) {
      if (contentsArea01.querySelector("#MAINAREA01")) {
        contentsArea01.classList.add("slc-contents-area-lg");
      } else if (contentsArea01.querySelector("#MAINAREA02_780")) {
        contentsArea01.classList.add("slc-contents-area-md");
      }
    } else {
      contentsArea01.classList.add("slc-contents-area-static");
    }
  } else if (middleArea) {
    const middleAreaM = middleArea.querySelector("#middleAreaM");
    const documentBody = document.querySelector("body");
    if (documentBody.getAttribute("data-design") === "seeds") {
      middleArea.classList.add("slc-middle-area-lg");
      middleAreaM == null ? void 0 : middleAreaM.classList.add("slc-middle-area-m");
    } else {
      middleArea.classList.add("slc-middle-area");
      middleAreaM == null ? void 0 : middleAreaM.classList.add("slc-middle-area-m");
    }
  }
};
slcSideNav.expandMarbleSideNav = () => {
  const targetElement = document.querySelector("#CONTENTSAREA01");
  if (!targetElement)
    return;
  if (slcCommon.isResponsive()) {
    targetElement.classList.add("slc-contents-area-mlg");
  } else {
    targetElement.classList.add("slc-contents-area-mmd");
  }
};
slcSideNav.expandSwitchSiteSideNav = () => {
  const targetElement = document.querySelector("body > table");
  const sideNavContainer = slcSideNav.expandController.closest("table");
  if (!targetElement || !sideNavContainer)
    return;
  const targetWidth = targetElement.getAttribute("width");
  const targetHeight = window.getComputedStyle(targetElement).height;
  const sideNavContainerWidth = sideNavContainer.getAttribute("width");
  if (targetWidth === "1232" && slcSideNav.expandController.dataset.localSideNavExpand === "false" && sideNavContainerWidth === "212") {
    targetElement.setAttribute("width", "1084");
    sideNavContainer.setAttribute("width", "88");
    sideNavContainer.style.setProperty("height", targetHeight);
    slcSideNav.expandController.parentElement.style.setProperty(
      "vertical-align",
      "top"
    );
  } else if (targetWidth === "1084" && slcSideNav.expandController.dataset.localSideNavExpand === "true" && sideNavContainerWidth === "88") {
    targetElement.setAttribute("width", "1232");
    sideNavContainer.setAttribute("width", "212");
    sideNavContainer.style.removeProperty("height");
    slcSideNav.expandController.parentElement.style.removeProperty(
      "vertical-align"
    );
  }
};
slcSideNav.toggleExpandSideNav = (isExpanded) => {
  var _a2, _b2, _c;
  const expandIcon = (_a2 = slcSideNav.expandTrigger) == null ? void 0 : _a2.querySelector("i");
  expandIcon == null ? void 0 : expandIcon.classList.toggle("slc-i-sidebar-left", !isExpanded);
  expandIcon == null ? void 0 : expandIcon.classList.toggle("slc-i-sidebar-right", isExpanded);
  (_b2 = slcSideNav.expandTrigger) == null ? void 0 : _b2.setAttribute("aria-expanded", !isExpanded);
  (_c = slcSideNav.expandTrigger) == null ? void 0 : _c.setAttribute(
    "title",
    isExpanded ? "\u30E1\u30CB\u30E5\u30FC\u3092\u958B\u304F" : "\u30E1\u30CB\u30E5\u30FC\u30FB\u6CE8\u610F\u4E8B\u9805\u3092\u9589\u3058\u308B"
  );
  slcSideNav.expandController.dataset.localSideNavExpand = !isExpanded;
  slcSideNav.expandSideNavSystemHandler();
};
slcSideNav.setSidenavExpandedCookie = (category, isExpanded) => {
  if (!category)
    return;
  const setData = slcSideNav.getSidenavExpandedCookie() ? slcSideNav.getSidenavExpandedCookie() : slcSideNav.expandedLists;
  setData[category] = isExpanded;
  const expires = new Date();
  expires.setFullYear(expires.getFullYear() + 1);
  document.cookie = "sidenav_expanded=" + JSON.stringify(setData) + "; expires=" + expires.toUTCString() + "; domain=.sbisec.co.jp; path=/";
};
slcSideNav.getSidenavExpandedCookie = () => {
  const cookies = document.cookie.split("; ").reduce((acc, cookie) => {
    const [key, value] = cookie.split("=");
    acc[key] = value;
    return acc;
  }, {});
  if (!cookies.sidenav_expanded)
    return false;
  const cookieExpandedLists = JSON.parse(cookies.sidenav_expanded);
  for (const key in slcSideNav.expandedLists) {
    if (Object.prototype.hasOwnProperty.call(cookieExpandedLists, key)) {
      slcSideNav.expandedLists[key] = cookieExpandedLists[key];
    }
  }
  return slcSideNav.expandedLists;
};
slcSideNav.handleExpandSideNav = () => {
  const isExpanded = slcSideNav.expandController.dataset.localSideNavExpand === "true";
  slcSideNav.toggleExpandSideNav(isExpanded);
  slcSideNav.setSidenavExpandedCookie(slcSideNav.sideNavCategory, !isExpanded);
};
slcSideNav.setExpandSideNav = () => {
  var _a2, _b2, _c, _d;
  slcSideNav.expandController = document.querySelector(
    "[data-local-side-nav-expand]"
  );
  slcSideNav.expandTrigger = (_a2 = slcSideNav.expandController) == null ? void 0 : _a2.querySelector(
    "[data-local-side-nav-expand-trigger]"
  );
  slcSideNav.sideNavCategory = (_b2 = document.querySelector(
    "[data-local-side-nav-category]"
  )) == null ? void 0 : _b2.dataset.localSideNavCategory;
  const cookieData = slcSideNav.getSidenavExpandedCookie();
  if (cookieData && cookieData[slcSideNav.sideNavCategory] === false) {
    slcSideNav.toggleExpandSideNav(true);
  }
  (_c = slcSideNav.expandTrigger) == null ? void 0 : _c.removeEventListener(
    "click",
    slcSideNav.handleExpandSideNav
  );
  (_d = slcSideNav.expandTrigger) == null ? void 0 : _d.addEventListener(
    "click",
    slcSideNav.handleExpandSideNav
  );
};
slcSideNav.isSideNavDisplayed = (query) => {
  const sideNavContents = document.querySelector(query);
  return sideNavContents && sideNavContents.hasChildNodes();
};
slcSideNav.observeUrl = () => {
  let previousUrl = "";
  const observer = new MutationObserver((mutations, observer2) => {
    if (location.href !== previousUrl) {
      previousUrl = location.href;
      slcSideNav.observeActive();
    }
  });
  const config = { subtree: true, childList: true };
  observer.observe(document, config);
};
slcSideNav.observeActive = () => {
  let loopTimer;
  const setupSideNav = () => {
    slcSideNav.setSwitchPage();
    slcSideNav.setActivePage();
    slcSideNav.setExpandSideNav();
    slcSideNav.switchEventListener();
    slcCommon.setUatUrl();
  };
  const observer = new MutationObserver((mutations) => {
    for (const mutation of mutations) {
      let sideNav = document.querySelector(
        "#local-dropdown-nav + .slc-local-side-nav"
      );
      if (slcCommon.screenMdQuery.matches) {
        sideNav = document.querySelector(
          "#local-side-nav + .slc-local-side-nav"
        );
      }
      if (slcCommon.getMemberCategory() === "FOREIGN") {
        if (slcSideNav.isSideNavDisplayed(
          '[data-uri="/seeds/common/side-menu/utf-8/foreign_side-menu_higher_contents.html"]'
        ) && slcSideNav.isSideNavDisplayed(
          '[data-uri^="/seeds/common/side-menu/utf-8/foreign_side-menu_middle"]'
        ) && slcSideNav.isSideNavDisplayed(
          '[data-uri="/seeds/common/side-menu/utf-8/foreign_side-menu_lower.html"]'
        )) {
          setupSideNav();
          slcSideNav.setLowerRelatedMenu();
          observer.disconnect();
          clearTimeout(loopTimer);
        }
      } else if (sideNav) {
        setupSideNav();
        observer.disconnect();
        clearTimeout(loopTimer);
      }
      if (loopTimer !== null)
        return;
      loopTimer = setTimeout(() => {
        loopTimer = null;
        observer.disconnect();
      }, 5e3);
    }
  });
  observer.observe(slcCommon.body, { subtree: true, childList: true });
};
window.addEventListener("resize", () => {
  clearTimeout(slcSideNav.sideNavTimer);
  slcSideNav.sideNavTimer = setTimeout(slcSideNav.switchEventListener(), 100);
});
window.visualViewport.addEventListener("resize", () => {
  slcSideNav.switchEventListener();
});
window.addEventListener("DOMContentLoaded", () => {
  slcSideNav.switchEventListener();
});
document.addEventListener("DOMContentLoaded", () => {
  slcSideNav.setActivePage();
  slcSideNav.observeUrl();
  slcSideNav.setLowerRelatedMenu();
  slcSideNav.setExpandSideNav();
});
slcCommon.screenMdQuery.addEventListener("change", () => {
  slcSideNav.switchEventListener();
  slcCommon.setUatUrl();
  slcSideNav.setSwitchPage();
});
var slcLocalLinkNav = slcLocalLinkNav || {};
slcLocalLinkNav.toggleShadow = () => {
  slcCommon.localLinkNav.addEventListener("scroll", () => {
    const navLinkPaddingLeft = window.getComputedStyle(slcCommon.localLinkNav).getPropertyValue("padding-left");
    const navLinkPaddingLeftNumber = parseInt(navLinkPaddingLeft, 10);
    if (parseInt(slcCommon.localLinkNav.scrollLeft) === 0) {
      slcCommon.localLinkNav.classList.add("slc-hide-left-shadow");
    } else if (parseInt(slcCommon.localLinkNav.scrollLeft) + document.documentElement.clientWidth === slcCommon.localLinkNav.querySelector('[aria-hidden="false"]').clientWidth + navLinkPaddingLeftNumber * 2) {
      slcCommon.localLinkNav.classList.add("slc-hide-right-shadow");
    } else {
      slcCommon.localLinkNav.classList.remove("slc-hide-right-shadow");
      slcCommon.localLinkNav.classList.remove("slc-hide-left-shadow");
    }
  });
};
slcLocalLinkNav.linkNavObserver = new MutationObserver((mutations) => {
  mutations.forEach((mutation) => {
    slcLocalLinkNav.linkNavObserver.disconnect();
    if (mutation.target.classList.contains("slc-nav-items")) {
      if (slcCommon.localLinkNav.querySelector('[aria-hidden="false"]')) {
        slcCommon.localLinkNav.setAttribute("aria-hidden", false);
        slcLocalLinkNav.toggleShadow();
        return;
      } else {
        slcCommon.localLinkNav.setAttribute("aria-hidden", true);
      }
    }
    slcLocalLinkNav.linkNavObserver.observe(
      slcCommon.localLinkNav,
      slcLocalLinkNav.linkNavObserverConfig
    );
  });
});
slcLocalLinkNav.linkNavObserverConfig = {
  attributes: true,
  attributeFilter: ["aria-hidden"],
  subtree: true
};
slcLocalLinkNav.linkNavObserver.observe(
  slcCommon.localLinkNav,
  slcLocalLinkNav.linkNavObserverConfig
);
var slcGlobalNav = slcGlobalNav || {};
slcGlobalNav.navItems = document.querySelectorAll("[data-global-nav-item]");
slcGlobalNav.dropdownContents = document.querySelectorAll(
  ".slc-dropdown-content"
);
slcGlobalNav.setActive = () => {
  const currentSystem = slcCommon.getSystem();
  if (currentSystem === "genesis") {
    const urlParams = typeof PAGE_PARAM !== "undefined" ? new URLSearchParams(PAGE_PARAM) : new URLSearchParams(window.location.search);
    const cat1 = urlParams.get("cat1");
    const dir = urlParams.get("dir");
    if (cat1 && dir)
      slcGlobalNav.setGenesisActive(cat1, dir);
  } else if (currentSystem === "marble") {
    const category1 = window.location.pathname.split("/")[2];
    if (category1 === "multiget")
      slcGlobalNav.setMarbleActive();
  } else if (currentSystem === "member") {
    let category1 = window.location.pathname.split("/")[1];
    if (category1 === "contents") {
      category1 = window.location.pathname.split("/")[2];
    }
    slcGlobalNav.setMemberActive(category1);
  } else if (currentSystem === "aqua") {
    const category1 = window.location.pathname.split("/")[1];
    const category2 = window.location.pathname.split("/")[2];
    slcGlobalNav.setAquaActive(category1, category2);
  } else if (currentSystem === "switchSite") {
  } else if (currentSystem === "midas") {
    slcGlobalNav.setMidasActive();
  }
};
slcGlobalNav.setAquaActive = (category1, category2) => {
  var _a2, _b2, _c, _d;
  let categoryLists = {
    nisa: { nav: "nisa", link: "nisa" },
    "foreign-mmf": { nav: "others", link: "fmmf" },
    wrap: { nav: "others", link: "wrap" },
    exchange: { link: "banking" },
    account: { link: "account" },
    assets: { link: "assets" }
  };
  let activeNav = (_a2 = categoryLists[category1]) == null ? void 0 : _a2.nav;
  let activeLink = (_b2 = categoryLists[category1]) == null ? void 0 : _b2.link;
  if (category1 === "account" && ["nisa", "wrap", "assets"].includes(category2) || category1 === "fund" && ["foreign-mmf"].includes(category2)) {
    activeNav = (_c = categoryLists[category2]) == null ? void 0 : _c.nav;
    activeLink = (_d = categoryLists[category2]) == null ? void 0 : _d.link;
  }
  if (activeNav) {
    const globalNavItem = document.getElementById(`${activeNav}-global-nav`);
    if (globalNavItem)
      globalNavItem.ariaCurrent = true;
  }
  if (activeLink) {
    const localNavItem = document.getElementById(`${activeLink}-local-nav`);
    if (localNavItem)
      localNavItem.ariaHidden = false;
  }
};
slcGlobalNav.setMemberActive = (category) => {
  var _a2, _b2;
  let categoryLists = {
    fund: { nav: "fund", link: "fund" },
    bond: { nav: "bond", link: "bond" },
    foreign: { nav: "foreign", link: "foreign" },
    fmmf: { nav: "others", link: "fmmf" },
    banking: { link: "banking" },
    "service-settings": { link: "service-settings" },
    "my-settings": { link: "home" }
  };
  let activeNav = (_a2 = categoryLists[category]) == null ? void 0 : _a2.nav;
  let activeLink = (_b2 = categoryLists[category]) == null ? void 0 : _b2.link;
  if (activeNav) {
    const globalNavItem = document.getElementById(`${activeNav}-global-nav`);
    if (globalNavItem)
      globalNavItem.ariaCurrent = true;
  }
  if (activeLink) {
    const localNavItem = document.getElementById(`${activeLink}-local-nav`);
    if (localNavItem)
      localNavItem.ariaHidden = false;
  }
};
slcGlobalNav.setMarbleActive = () => {
  var _a2, _b2;
  const urlParams = new URLSearchParams(window.location.search);
  const param6 = urlParams.get("Param6");
  const category = param6 == null ? void 0 : param6.split(".")[0];
  let categoryLists = {
    home: { nav: "home", link: "home" },
    market: { nav: "market", link: "market" },
    domestic: { nav: "domestic", link: "domestic" },
    foreign: { nav: "foreign", link: "foreign" },
    fund: { nav: "fund", link: "fund" },
    bond: { nav: "bond", link: "bond" },
    exchange: { nav: "fx", link: "fx" },
    derivative: { nav: "others", link: "futures-option" },
    cfdwarrant: { nav: "others", link: "cfd" },
    gbi: { nav: "others", link: "gold" },
    nisa: { nav: "nisa", link: "nisa" },
    dc: { nav: "others", link: "ideco" },
    dc401k: { nav: "others", link: "ideco" },
    bank: { link: "bank" },
    insurance: { link: "insurance" }
  };
  let activeNav = (_a2 = categoryLists[category]) == null ? void 0 : _a2.nav;
  let activeLink = (_b2 = categoryLists[category]) == null ? void 0 : _b2.link;
  if (activeNav) {
    const globalNavItem = document.getElementById(`${activeNav}-global-nav`);
    if (globalNavItem)
      globalNavItem.ariaCurrent = true;
  }
  if (activeLink) {
    const localNavItem = document.getElementById(`${activeLink}-local-nav`);
    if (localNavItem)
      localNavItem.ariaHidden = false;
  }
};
slcGlobalNav.setGenesisActive = (category, directory) => {
  var _a2, _b2, _c, _d;
  directory = directory.replace("/", "");
  let categoryLists = {
    home: { nav: "home", link: "home" },
    market: { nav: "market", link: "market" },
    domestic: { nav: "domestic", link: "domestic" },
    foreign: { nav: "foreign", link: "foreign" },
    fund: { nav: "fund", link: "fund" },
    bond: { nav: "bond", link: "bond" },
    fx: { nav: "fx", link: "fx" },
    op: { nav: "others", link: "futures-option" },
    cx: { nav: "others", link: "odex" },
    cfd: { nav: "others", link: "cfd" },
    otccfd: { nav: "others", link: "otc-cfd" },
    gold: { nav: "others", link: "gold" },
    nisa: { nav: "nisa", link: "nisa" },
    dc: { nav: "others", link: "ideco" },
    bank: { link: "bank" },
    other: { link: "insurance" },
    stockop: { nav: "others", link: "domestic-option" },
    st: { nav: "others", link: "st" },
    wrap: { nav: "others", link: "wrap" },
    robot: { nav: "others", link: "robot" },
    support: { link: "support" },
    fmmf: { nav: "others", link: "fmmf" }
  };
  let activeNav = (_a2 = categoryLists[category]) == null ? void 0 : _a2.nav;
  let activeLink = (_b2 = categoryLists[category]) == null ? void 0 : _b2.link;
  if (category === "home" && ["st", "wrap", "robot", "support"].includes(directory) || category === "domestic" && ["stockop"].includes(directory)) {
    activeNav = (_c = categoryLists[directory]) == null ? void 0 : _c.nav;
    activeLink = (_d = categoryLists[directory]) == null ? void 0 : _d.link;
  }
  if (activeNav) {
    const globalNavItem = document.getElementById(`${activeNav}-global-nav`);
    if (globalNavItem)
      globalNavItem.ariaCurrent = true;
  }
  if (activeLink) {
    const localNavItem = document.getElementById(`${activeLink}-local-nav`);
    if (localNavItem)
      localNavItem.ariaHidden = false;
  }
};
slcGlobalNav.setMidasActive = () => {
  const globalNavItem = document.getElementById(`others-global-nav`);
  if (globalNavItem)
    globalNavItem.ariaCurrent = true;
  const localNavItem = document.getElementById(`gold-local-nav`);
  if (localNavItem)
    localNavItem.ariaHidden = false;
};
slcGlobalNav.openContent = (dropdownContent) => {
  slcGlobalNav.navItems.forEach((item) => {
    slcGlobalNav.closeContent(item.querySelector(".slc-dropdown-content"));
  });
  const dropdownItem = dropdownContent == null ? void 0 : dropdownContent.closest("[data-global-nav-item]");
  const isExpanded = (dropdownContent == null ? void 0 : dropdownContent.getAttribute("aria-expanded")) === "true";
  dropdownContent == null ? void 0 : dropdownContent.setAttribute("aria-expanded", !isExpanded);
  dropdownItem == null ? void 0 : dropdownItem.setAttribute("aria-expanded", !isExpanded);
};
slcGlobalNav.closeContent = (dropdownContent) => {
  var _a2;
  dropdownContent == null ? void 0 : dropdownContent.setAttribute("aria-expanded", false);
  (_a2 = dropdownContent == null ? void 0 : dropdownContent.closest('[data-global-nav-item="dropdown"]')) == null ? void 0 : _a2.setAttribute("aria-expanded", false);
};
slcGlobalNav.setDropdown = () => {
  let openTimer;
  let closeTimer;
  let hasTouch2 = false;
  slcGlobalNav.navItems.forEach((navItem) => {
    var _a2, _b2, _c;
    const dropdownItem = ((_a2 = navItem.dataset.globalNavItem) == null ? void 0 : _a2.includes("dropdown")) ? navItem : null;
    const dropdownContent = navItem.querySelector(".slc-dropdown-content");
    dropdownItem == null ? void 0 : dropdownItem.addEventListener("mouseenter", () => {
      if (!hasTouch2) {
        if (closeTimer) {
          clearTimeout(closeTimer);
        }
        openTimer = setTimeout(slcGlobalNav.openContent, 200, dropdownContent);
      }
      hasTouch2 = false;
    });
    dropdownItem == null ? void 0 : dropdownItem.addEventListener("mouseleave", () => {
      if (openTimer) {
        clearTimeout(openTimer);
      }
      closeTimer = setTimeout(slcGlobalNav.closeContent, 200, dropdownContent);
    });
    dropdownItem == null ? void 0 : dropdownItem.querySelector(".slc-nav-link").addEventListener("touchstart", (e) => {
      hasTouch2 = true;
      if (navItem.getAttribute("aria-expanded") === "true" || !navItem.classList.contains("slc-mega-menu")) {
        slcGlobalNav.closeContent(dropdownContent);
      } else {
        slcGlobalNav.openContent(dropdownContent);
      }
    });
    navItem.addEventListener("mousedown", (e) => {
      e.preventDefault();
    });
    (_b2 = navItem == null ? void 0 : navItem.querySelector(".slc-nav-link")) == null ? void 0 : _b2.addEventListener("focus", () => {
      if (closeTimer) {
        clearTimeout(closeTimer);
      }
      const currentNav = navItem == null ? void 0 : navItem.querySelector(".slc-nav-link");
      openTimer = setTimeout(() => {
        if (document.activeElement === currentNav) {
          slcGlobalNav.openContent(dropdownContent);
        }
      }, 100);
    });
    let navItemLinks = navItem.querySelectorAll(".slc-nav-link");
    navItemLinks.forEach((navItemLink) => {
      navItemLink.addEventListener("blur", (e) => {
        var _a3;
        if (!((_a3 = e.relatedTarget) == null ? void 0 : _a3.closest("[data-global-nav-item]"))) {
          navItem.querySelector(".slc-dropdown-content").setAttribute("aria-expanded", false);
          navItem.setAttribute("aria-expanded", false);
        }
      });
    });
    if (navItem.getAttribute("data-global-nav-item") === "dropdown" && navItem.querySelector(".slc-new,.slc-badge")) {
      (_c = document.getElementById("others-global-nav")) == null ? void 0 : _c.insertAdjacentHTML(
        "afterbegin",
        '<span class="slc-badge slc-notice">NEW</span>'
      );
    }
  });
};
slcGlobalNav.lastScrollPosition = 0;
slcGlobalNav.handleScrollAnimation = () => {
  const scrollHideItems = document.querySelectorAll("[data-scroll-hide]");
  let unScrollAnimationArea = 0;
  scrollHideItems.forEach((scrollHideItem) => {
    if (!scrollHideItem.classList.contains("slc-local-link-nav") || scrollHideItem.querySelector("[aria-hidden=false]")) {
      unScrollAnimationArea += scrollHideItem.offsetHeight;
    }
  });
  const scrollPosition = window.scrollY || document.documentElement.scrollTop;
  scrollHideItems.forEach((scrollHideItem) => {
    if (!scrollHideItem.classList.contains("slc-local-link-nav") || scrollHideItem.querySelector("[aria-hidden=false]")) {
      if (scrollPosition > unScrollAnimationArea) {
        scrollHideItem.setAttribute(
          "aria-hidden",
          scrollPosition > slcGlobalNav.lastScrollPosition
        );
      } else {
        scrollHideItem.setAttribute("aria-hidden", false);
      }
    }
  });
  slcGlobalNav.lastScrollPosition = scrollPosition;
};
slcGlobalNav.showScrollHideItems = () => {
  const scrollHideItems = document.querySelectorAll("[data-scroll-hide]");
  scrollHideItems.forEach((scrollHideItem) => {
    if (scrollHideItem.classList.contains("slc-local-link-nav") && !scrollHideItem.querySelector('.slc-nav-items[aria-hidden="false"]')) {
      return;
    }
    scrollHideItem.setAttribute("aria-hidden", false);
  });
};
slcGlobalNav.switchEventListener = () => {
  if (!slcCommon.screenMdQuery.matches) {
    window.addEventListener("scroll", slcGlobalNav.handleScrollAnimation);
    slcCommon.clearEventListener();
    slcGlobalNav.dropdownContents.forEach((navDropdownContent) => {
      slcGlobalNav.closeContent(navDropdownContent);
    });
  } else {
    window.removeEventListener("scroll", slcGlobalNav.handleScrollAnimation);
    slcGlobalNav.showScrollHideItems();
  }
};
slcCommon.screenMdQuery.addEventListener("change", () => {
  slcGlobalNav.switchEventListener();
});
document.addEventListener("click", (e) => {
  if (!e.target.closest('[data-global-nav-item="dropdown"]') && slcCommon.screenMdQuery.matches) {
    slcGlobalNav.dropdownContents.forEach((navDropdownContent) => {
      slcGlobalNav.closeContent(navDropdownContent);
    });
  }
});
document.addEventListener("DOMContentLoaded", () => {
  slcGlobalNav.setActive();
  slcGlobalNav.setDropdown();
  slcGlobalNav.switchEventListener();
});
var slcBulletin = slcBulletin || {};
slcBulletin.createBulletinElement = (bulletinContent) => {
  return `<article class="slc-bulletin">
            <p><i class="slc-i-error-fill"></i>${bulletinContent}</p>
          </article>`;
};
slcBulletin.setMemberBulletin = (productName, dataBulletin) => {
  const param = {
    site: productName
  };
  const endPoint = `/system/api/notice/bulletin`;
  const response = slcCommon.callGetApi(endPoint, param);
  response.then((res) => {
    if (res.data.content) {
      dataBulletin.innerHTML = slcBulletin.createBulletinElement(
        res.data.content
      );
    }
  }).catch((error) => {
    console.error(error);
  });
};
slcBulletin.setBulletinContent = () => {
  var _a2, _b2;
  const currentSystem = slcCommon.getSystem();
  const dataBulletin = document.querySelector("[data-bulletin-contents]");
  if (currentSystem === "member") {
    const url = window.location.pathname;
    let current = url.split("/")[1].toUpperCase().replace(/-/g, "_");
    if (current === "CONTENTS") {
      current = url.split("/")[2].toUpperCase().replace(/-/g, "_");
    }
    if (current === "FOREIGN") {
      return;
    }
    slcBulletin.setMemberBulletin(current, dataBulletin);
  } else if (currentSystem !== "aqua" && currentSystem !== "midas") {
    const bulletinTarget = document.querySelector("[data-responsive-page]") || document.querySelector("[data-header-bulletin]");
    if (!bulletinTarget)
      return;
    const bulletinId = document.getElementById("bulletin-container");
    const bulletinContentElement = (_a2 = document.querySelector(
      "[src*='/sbisec/images/common/common/i_attention_gray.gif']"
    )) == null ? void 0 : _a2.closest('[class^="mbody"]');
    const bulletinContent = bulletinId || bulletinContentElement;
    let bulletinText = "";
    (_b2 = bulletinContent == null ? void 0 : bulletinContent.childNodes) == null ? void 0 : _b2.forEach((node) => {
      if (node.nodeType === Node.TEXT_NODE) {
        bulletinText += node.textContent.trim();
      } else if (node.nodeName === "BR") {
        bulletinText += "<br>";
      } else if (node.nodeName === "A") {
        bulletinText += node.outerHTML;
      }
    });
    if (bulletinText) {
      bulletinContentElement.style.display = "none";
    }
    if (bulletinText && bulletinTarget) {
      const bulletinArea = document.getElementById("BULLETINAREA");
      if (bulletinArea) {
        bulletinArea.innerHTML = `<div data-design="seeds-layout">${slcBulletin.createBulletinElement(
          bulletinText
        )}</div>`;
      } else {
        dataBulletin.innerHTML = slcBulletin.createBulletinElement(bulletinText);
      }
    }
  }
};
document.addEventListener("DOMContentLoaded", () => {
  slcBulletin.setBulletinContent();
});
document.addEventListener("DOMContentLoaded", () => {
  const isCustomer = slcCommon.getIsLogin();
  if (isCustomer) {
    const cookieData = slcCommon.getCookieObject();
    if (cookieData) {
      const intermediaryProfile = (data) => {
        if (data.code == "0000" || data.code == null)
          return;
        if (data.isShinkin) {
          const bankTexts = document.querySelectorAll("[data-bank-text]");
          bankTexts.forEach((bankText) => {
            bankText.innerHTML = '<i class="slc-i-building-columns slc-nav-link-icon"></i>\u4FE1\u91D1';
          });
        }
        if (data.url) {
          const a = document.createElement("a");
          Object.assign(a, {
            href: data.url,
            classList: "slc-intermediary",
            target: "_blank"
          });
          const img = document.createElement("img");
          const PATH = "/sbisec/images/common/logo/intermediary";
          let cdnUrl = "https://sbisec.akamaized.net";
          if (!(typeof CDN_URL == "undefined"))
            cdnUrl = CDN_URL;
          if (!(typeof AKAMAI_URL == "undefined"))
            cdnUrl = AKAMAI_URL;
          Object.assign(img, {
            src: `${cdnUrl + PATH}/${data.code}.gif`,
            alt: `${data.name}\u30ED\u30B4`,
            onerror: () => {
              slcCommon.removeElement(
                document.querySelector(".slc-intermediary")
              );
            }
          });
          a.appendChild(img);
          document.querySelector(".slc-nav-logo").appendChild(a);
          const navLogoSpace = document.querySelector(
            ".slc-nav-logo > .slc-logo-space"
          );
          navLogoSpace.style.marginRight = "0px";
        }
      };
      intermediaryProfile(cookieData == null ? void 0 : cookieData.intermediaryProfile);
    }
  }
});
var slcHeader = slcHeader || {};
slcHeader.headerNav = document.querySelector(".slc-header > .slc-header-nav");
slcHeader.dotsMenu = document.querySelector("[data-dots-menu]");
slcHeader.headerNavUpperItems = document.querySelectorAll(
  ".slc-header-nav-upper-menu [data-nav-item]"
);
slcHeader.headerNavUpperMenus = Array.from(
  slcHeader.headerNavUpperItems
).filter((navItem) => navItem.getAttribute("data-nav-item") !== "search");
slcHeader.headerNavSearchItem = slcHeader.headerNav.querySelector(
  '.slc-header-nav-upper-menu [data-search="trigger"]'
);
slcHeader.headerNavLowerItems = slcHeader.headerNav.querySelectorAll(
  ".slc-header-nav-lower-menu [data-nav-item]"
);
slcHeader.headerNavLowerMenus = Array.from(
  slcHeader.headerNavLowerItems
).filter(
  (navItem) => navItem.getAttribute("data-nav-item") !== "login" && navItem.getAttribute("data-nav-item") !== "account-opening"
);
slcHeader.headerNavLogout = slcHeader.headerNav.querySelector(
  '.slc-header-nav-lower-menu [data-nav-item="login"]'
);
slcHeader.headerNavAccountOpening = slcHeader.headerNav.querySelector(
  '.slc-header-nav-lower-menu [data-nav-item="account-opening"]'
);
slcHeader.headerTimer;
slcHeader.headerDropdownItems = document.querySelectorAll(
  '[data-nav-item="dropdown"]'
);
slcHeader.brandSearchInput = document.getElementById("brand-search-text");
slcHeader.brandSearchCategory = document.getElementById(
  "brand-search-category"
);
slcHeader.openHeaderDropdownContent = (headerItem) => {
  headerItem == null ? void 0 : headerItem.setAttribute("aria-expanded", true);
};
slcHeader.switchHeaderDropdownContent = () => {
  slcHeader.headerDropdownItems.forEach((headerDropdownItem) => {
    let openTimer;
    let closeTimer;
    let hasTouch2 = false;
    headerDropdownItem.addEventListener("mouseenter", (e) => {
      if (!hasTouch2) {
        slcCommon.closeHeaderDropdownContent();
        if (openTimer) {
          clearTimeout(openTimer);
        }
        openTimer = setTimeout(
          slcHeader.openHeaderDropdownContent,
          200,
          e.target
        );
      }
      hasTouch2 = false;
    });
    headerDropdownItem == null ? void 0 : headerDropdownItem.addEventListener("mouseleave", (e) => {
      if (openTimer) {
        clearTimeout(openTimer);
      }
      closeTimer = setTimeout(slcCommon.closeHeaderDropdownContent);
    });
    let headerDropdownItemLinks = headerDropdownItem.querySelectorAll(".slc-nav-link");
    headerDropdownItemLinks.forEach((headerDropdownItemLink) => {
      headerDropdownItemLink.addEventListener("blur", (e) => {
        const currentNavItem = headerDropdownItemLink.closest("[data-nav-item]");
        if (e.relatedTarget) {
          const targetNavItem = e.relatedTarget.closest("[data-nav-item]");
          if (currentNavItem !== targetNavItem) {
            headerDropdownItem.setAttribute("aria-expanded", false);
          }
        } else {
          headerDropdownItem.setAttribute("aria-expanded", false);
        }
      });
    });
    headerDropdownItem.querySelector(".slc-nav-link.slc-min-display-md").addEventListener("touchstart", (e) => {
      hasTouch2 = true;
      if (openTimer) {
        clearTimeout(openTimer);
      }
      if (headerDropdownItem.getAttribute("aria-expanded") === "true" || headerDropdownItem.getAttribute("aria-expanded") === "false" && headerDropdownItem.closest(".slc-dropdown-menu") === null) {
        slcCommon.closeHeaderDropdownContent();
      } else {
        slcCommon.closeHeaderDropdownContent();
        slcHeader.openHeaderDropdownContent(headerDropdownItem);
      }
    });
    headerDropdownItem.addEventListener("mousedown", (e) => {
      e.preventDefault();
    });
  });
  slcHeader.headerNavLowerMenus.forEach((navItem) => {
    var _a2;
    let openTimer;
    let closeTimer;
    (_a2 = navItem == null ? void 0 : navItem.querySelector(".slc-nav-link:not(.slc-max-display-sm)")) == null ? void 0 : _a2.addEventListener("focus", (e) => {
      var _a3;
      slcCommon.closeHeaderDropdownContent();
      if (navItem.getAttribute("data-nav-item") === "dropdown") {
        if (openTimer) {
          clearTimeout(openTimer);
        }
        openTimer = setTimeout(
          slcHeader.openHeaderDropdownContent(
            (_a3 = e.target.parentElement) == null ? void 0 : _a3.parentElement
          ),
          100,
          e.target
        );
      }
    });
  });
};
slcHeader.adjustDotsMenu = () => {
  var _a2;
  const headerNavMenuItems = slcHeader.headerNav.querySelector(
    ".slc-header-nav-lower-menu > .slc-nav-items"
  );
  if (headerNavMenuItems) {
    (_a2 = slcHeader.dotsMenu) == null ? void 0 : _a2.classList.remove("slc-hide");
  }
};
slcHeader.createDotsMenuItems = () => {
  var _a2;
  const cloneNavItems = [
    ...slcHeader.headerNavLowerMenus,
    ...slcHeader.headerNavUpperMenus
  ];
  const isCustomer = slcCommon.getIsLogin();
  if (isCustomer) {
    cloneNavItems.push(slcHeader.headerNavLogout);
    document.querySelector(".slc-announce-container").classList.remove("slc-hide");
    (_a2 = slcHeader.headerNavLogout) == null ? void 0 : _a2.classList.add("slc-logout");
  } else {
    slcHeader.headerNavAccountOpening.classList.remove("slc-hide");
    cloneNavItems.unshift(slcHeader.headerNavAccountOpening);
  }
  cloneNavItems.forEach((item) => {
    var _a3;
    const cloneNode = item.cloneNode(true);
    (_a3 = slcCommon.dotsMenuButton) == null ? void 0 : _a3.firstElementChild.appendChild(cloneNode);
  });
};
slcHeader.setDotsMenuAccordion = () => {
  document.querySelectorAll(".slc-dots-menu .slc-nav-accordion-item").forEach((item) => {
    item == null ? void 0 : item.addEventListener("click", (e) => {
      const isExpanded = item.getAttribute("aria-expanded") === "true";
      item.setAttribute("aria-expanded", !isExpanded);
      item.querySelector(".slc-plus-switch > input").checked = !isExpanded;
    });
  });
};
slcHeader.setGlobalHamburger = () => {
  var _a2;
  (_a2 = slcCommon.globalHamburger) == null ? void 0 : _a2.addEventListener("click", (event) => {
    var _a3, _b2;
    if (event.target.checked) {
      (_a3 = slcCommon.globalHamburger) == null ? void 0 : _a3.setAttribute(
        "aria-expanded",
        event.target.checked
      );
      slcCommon.closeDotsMenu();
      slcCommon.closeSearchDropdown();
      (_b2 = slcCommon.globalNav) == null ? void 0 : _b2.setAttribute("aria-expanded", event.target.checked);
      slcCommon.showOverlay();
      return;
    }
    slcCommon.hideOverlay();
    slcCommon.closeHamburgerMenu();
  });
};
slcHeader.setDotsMenu = () => {
  var _a2;
  (_a2 = slcCommon.dotsMenuTrigger) == null ? void 0 : _a2.addEventListener("change", (event) => {
    var _a3;
    const dotsMenu = event.target;
    const isOpen = (dotsMenu == null ? void 0 : dotsMenu.getAttribute("aria-expanded")) === "true";
    slcCommon.dotsMenuTrigger.querySelector("input").checked = !isOpen;
    (_a3 = slcCommon.dotsMenuTrigger) == null ? void 0 : _a3.querySelector("input").setAttribute("aria-expanded", !isOpen);
    slcCommon.dotsMenuButton.setAttribute("aria-expanded", !isOpen);
    if (!isOpen) {
      slcCommon.showOverlay();
      slcCommon.closeHamburgerMenu();
      slcCommon.closeSearchDropdown();
    } else {
      slcCommon.hideOverlay();
    }
  });
};
slcHeader.toggleLogin = () => {
  const isCustomer = slcCommon.getIsLogin();
  const loginAnchor = document.querySelector('[data-nav-item="login"] a');
  if (isCustomer) {
    const switchLoginIcon = document.querySelector('[data-nav-item="login"] i');
    const switchLoginText = document.querySelector(
      '[data-nav-item="login"] .slc-nav-link-title'
    );
    switchLoginIcon.classList.toggle("slc-i-login", !isCustomer);
    switchLoginIcon.classList.toggle("slc-i-logout", isCustomer);
    switchLoginText.innerHTML = isCustomer ? "\u30ED\u30B0\u30A2\u30A6\u30C8" : "\u30ED\u30B0\u30A4\u30F3";
  }
  loginAnchor.classList.remove("slc-hide");
};
slcHeader.isSearchScriptLoaded = () => {
  return !!document.body.querySelector(
    'script[src="https://cse.google.com/cse.js?cx=e14878f5cdb3e4795"]'
  );
};
slcHeader.insertSearchScript = () => {
  const script = document.createElement("script");
  script.src = "https://cse.google.com/cse.js?cx=e14878f5cdb3e4795";
  script.async = true;
  document.head.appendChild(script);
};
slcHeader.setSiteSearchClickLog = (query) => {
  const siteSearchLinks = document.querySelectorAll(".slc-modal a");
  siteSearchLinks == null ? void 0 : siteSearchLinks.forEach((siteSearchLink) => {
    const url = siteSearchLink.getAttribute("data-ctorig");
    if (!url || !url.includes("sbisec.co.jp")) {
      return;
    }
    siteSearchLink.addEventListener("click", () => {
      window.dataLayer.push({
        event: "site_search_result_click",
        search_term: query,
        search_result_click_url: url
      });
    });
  });
};
slcHeader.setSiteSearchCallbacks = () => {
  var _a2, _b2, _c, _d, _e, _f;
  const originalGcseWebRendered = (_c = (_b2 = (_a2 = window.__gcse) == null ? void 0 : _a2.searchCallbacks) == null ? void 0 : _b2.web) == null ? void 0 : _c.rendered;
  window.__gcse = {
    ...window.__gcse,
    searchCallbacks: {
      ...(_d = window.__gcse) == null ? void 0 : _d.searchCallbacks,
      web: {
        ...(_f = (_e = window.__gcse) == null ? void 0 : _e.searchCallbacks) == null ? void 0 : _f.web,
        rendered: (...args) => {
          originalGcseWebRendered == null ? void 0 : originalGcseWebRendered(...args);
          slcHeader.setSiteSearchClickLog(args[1]);
        }
      }
    }
  };
};
slcHeader.openSiteSearch = () => {
  var _a2, _b2, _c, _d;
  const modal = document.querySelector(".slc-modal");
  const searchSiteInput = ((_b2 = (_a2 = document.querySelector("#site-search")) == null ? void 0 : _a2.value) != null ? _b2 : "").trim();
  if ((modal == null ? void 0 : modal.getAttribute("aria-hidden")) === "true" && searchSiteInput.length > 0) {
    modal.setAttribute("aria-hidden", "false");
    window.dataLayer = window.dataLayer || [];
    window.dataLayer.push({
      event: "site_search",
      search_term: searchSiteInput
    });
    (_c = modal.querySelector("input")) == null ? void 0 : _c.focus();
    (_d = document.querySelector(".slc-modal-body")) == null ? void 0 : _d.scrollTo(0, 0);
    document.getElementById("gsc-i-id1").value = searchSiteInput;
    document.querySelector(".gsc-search-button-v2").click();
    slcCommon.showModalOverlay();
  }
};
slcHeader.siteSearchObserver = new MutationObserver(() => {
  const searchButton = document.querySelector(".gsc-search-button-v2");
  const modalSearchInput = document.getElementById("gsc-i-id1");
  if (searchButton && modalSearchInput) {
    slcHeader.openSiteSearch();
    slcHeader.siteSearchObserver.disconnect();
  }
});
slcHeader.setModal = () => {
  const searchButton = document.querySelector(".gsc-search-button-v2");
  const modalSearchInput = document.getElementById("gsc-i-id1");
  const modal = document.querySelector(".slc-modal");
  if (searchButton && modalSearchInput) {
    slcHeader.openSiteSearch();
  } else {
    slcHeader.siteSearchObserver.observe(modal, {
      childList: true,
      subtree: true
    });
    if (!slcHeader.isSearchScriptLoaded()) {
      slcHeader.insertSearchScript();
    }
  }
};
slcHeader.searchSite = () => {
  var _a2, _b2, _c, _d;
  const modal = document.querySelector(".slc-modal");
  modal == null ? void 0 : modal.addEventListener("keydown", (e) => {
    const modalInput = modal == null ? void 0 : modal.querySelector("input");
    const modalCloseButton = modal == null ? void 0 : modal.querySelector(".slc-modal-close");
    if (e.key === "Tab" && e.shiftKey && document.activeElement == modalInput) {
      e.preventDefault();
      modalCloseButton.focus();
    } else if (e.key === "Tab" && !e.shiftKey && document.activeElement == modalCloseButton) {
      e.preventDefault();
      modalInput.focus();
    }
  });
  (_a2 = document.querySelector("#site-search")) == null ? void 0 : _a2.addEventListener("keydown", (e) => {
    if (e.key === "Enter") {
      slcHeader.setModal();
    }
  });
  (_c = (_b2 = document.querySelector(".slc-site-search-box")) == null ? void 0 : _b2.querySelector(".slc-search-button")) == null ? void 0 : _c.addEventListener("click", () => {
    slcHeader.setModal();
  });
  (_d = document.querySelector(".slc-modal-close")) == null ? void 0 : _d.addEventListener("click", () => {
    modal == null ? void 0 : modal.setAttribute("aria-hidden", "true");
    slcCommon.hideModalOverlay();
    slcCommon.hideOverlay();
  });
};
slcHeader.toggleSearchDropdown = () => {
  var _a2;
  (_a2 = slcHeader.headerNavSearchItem) == null ? void 0 : _a2.addEventListener("click", (e) => {
    var _a3;
    const isOpen = ((_a3 = slcHeader.headerNavSearchItem) == null ? void 0 : _a3.getAttribute("aria-expanded")) === "true";
    slcHeader.headerNavSearchItem.setAttribute("aria-expanded", !isOpen);
    if (!isOpen) {
      slcCommon.showOverlay();
      document.addEventListener("click", slcHeader.triggerSearchDropdown);
      slcCommon.closeHamburgerMenu();
      slcCommon.closeDotsMenu();
    } else {
      document.removeEventListener("click", slcHeader.triggerSearchDropdown);
      slcCommon.hideOverlay();
    }
  });
};
slcHeader.triggerSearchDropdown = (e) => {
  if (!(e.target.closest(".slc-search-dropdown") || e.target.closest(".slc-header-nav") || e.target.closest(".slc-search-suggest-items"))) {
    slcCommon.closeSearchDropdown();
  }
};
slcHeader.searchForeign = (searchText) => {
  if (searchText) {
    const convertSearchText = Encoding.convert(
      Encoding.stringToCode(searchText),
      {
        to: "SJIS",
        from: "UNICODE",
        fallback: "ignore"
      }
    );
    const encodeQuery = Encoding.urlEncode(convertSearchText);
    const mainSiteBaseUrl = "https://www.sbisec.co.jp";
    const mainSiteUrl = typeof MAIN_SITE_URL == "undefined" ? mainSiteBaseUrl : MAIN_SITE_URL;
    window.location.href = mainSiteUrl + `/ETGate/?_ControlID=WPLETsmR001Control&_PageID=WPLETsmR001Sdtl23&_ActionID=NoActionID&_DataStoreID=DSWPLETsmR001Control&OutSide=on&getFlg=on&path=foreign%2Fhome%2Fstock%3FstockName%3D${encodeQuery}%26searchType%3Dinclude`;
  }
};
slcHeader.searchFund = (searchText) => {
  if (searchText) {
    const convertSearchText = Encoding.convert(
      Encoding.stringToCode(searchText),
      {
        to: "SJIS",
        from: "UNICODE",
        fallback: "ignore"
      }
    );
    const encodeQuery = Encoding.urlEncode(convertSearchText);
    const mainSiteBaseUrl = "https://www.sbisec.co.jp";
    const mainSiteUrl = typeof MAIN_SITE_URL == "undefined" ? mainSiteBaseUrl : MAIN_SITE_URL;
    window.location.href = mainSiteUrl + `/ETGate/?_ControlID=WPLETsmR001Control&_PageID=WPLETsmR001Sdtl23&_DataStoreID=DSWPLETsmR001Control&_ActionID=NoActionID&getFlg=on&OutSide=on&path=fund%2Fsearch%3FsearchKeywordsValue%3D${encodeQuery}`;
  }
};
slcHeader.encode = (str) => {
  return str.replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;").replace(/"/g, "&quot;").replace(/'/g, "&#39;");
};
slcHeader.fetch = (condition) => {
  const query = new URLSearchParams(condition.params).toString();
  fetchJsonp(condition.uri + "?" + query, {
    jsonpCallback: condition.callback,
    timeout: 3e3
  }).then((response) => {
    response.json();
  }).catch(() => {
  });
};
slcHeader.getMainSiteUrl = (url) => {
  const mainSiteBaseUrl = "https://www.sbisec.co.jp";
  const mainSiteUrl = typeof MAIN_SITE_URL == "undefined" ? mainSiteBaseUrl : MAIN_SITE_URL;
  const BASE_URLS = /* @__PURE__ */ new Map();
  BASE_URLS.set(mainSiteBaseUrl, mainSiteUrl);
  const originUrl = new URL(url).origin;
  const baseUrl = BASE_URLS.get(originUrl);
  return baseUrl == null ? url : url.replace(originUrl, mainSiteUrl);
};
slcHeader.removeSuggest = (id) => {
  const parent = document.querySelector(id);
  parent.innerHTML = "";
  parent.setAttribute("aria-hidden", true);
};
slcHeader.removeRight = () => {
  const rights = document.querySelectorAll(".slc-header-suggest-right");
  for (let i = 0; i < rights.length; i++) {
    if (rights[i].textContent !== "") {
      return;
    }
  }
  for (let i = 0; i < rights.length; i++) {
    if (rights[i].parentNode != null) {
      rights[i].parentNode.removeChild(rights[i]);
    }
  }
};
slcHeader.getOption = () => {
  const cookieData = slcCommon.getCookieObject();
  const aHash = (cookieData == null ? void 0 : cookieData.aHash) || "";
  const hHash = (cookieData == null ? void 0 : cookieData.hHash) || "";
  const params = {
    id: aHash,
    hash: hHash,
    callback: "slcHeader.submitStock"
  };
  slcHeader.fetch({
    uri: "https://i.sbisec.co.jp/api/getOptionApi.jsp",
    params,
    callback: "slcHeader.submitStock"
  });
};
slcHeader.submitStock = (data) => {
  const { keyword, hyoji, yosoku, page, numCode } = data;
  const value = document.querySelector("#brand-search-text").value;
  if (value == null || value === "") {
    return;
  }
  const cookieData = slcCommon.getCookieObject();
  const aHash = (cookieData == null ? void 0 : cookieData.aHash) || "";
  const hHash = (cookieData == null ? void 0 : cookieData.hHash) || "";
  const params = {
    id: aHash,
    hash: hHash,
    inputWord: slcHeader.encode(value),
    callback: "slcHeader.onSubmitStock",
    keyword,
    sort: hyoji,
    logOnOff: "1",
    numCode,
    page,
    suggest: yosoku
  };
  slcHeader.fetch({
    uri: "https://i.sbisec.co.jp/api/jStockSearchApi.jsp",
    params,
    callback: "slcHeader.onSubmitStock"
  });
};
slcHeader.brandSearchInput.addEventListener("input", (e) => {
  const selectedCategory = slcHeader.brandSearchCategory.options[slcHeader.brandSearchCategory.selectedIndex].value;
  if (selectedCategory === "domestic") {
    const value = e.target.value.trim();
    const searchSuggest = document.querySelector("#stock-search-autocomplete");
    if (value == null || value.length < 2) {
      searchSuggest.setAttribute("aria-hidden", true);
      return;
    }
    const params = {
      charset: "U",
      channel: "2",
      term: slcHeader.encode(value),
      callback: "slcHeader.onStockSuggest"
    };
    slcHeader.fetch({
      uri: "https://i.sbisec.co.jp/api/jStockSuggestGP.jsp",
      params,
      callback: "slcHeader.onStockSuggest"
    });
  } else
    return;
});
slcHeader.searchSuggestArea = document.querySelector(
  "#stock-search-autocomplete"
);
let isKeyNavigating = false;
let listContainer;
slcHeader.onStockSuggest = (list) => {
  slcHeader.removeSuggest("#stock-search-autocomplete");
  if (list == null || list.stocks.length === 0) {
    return;
  }
  const parent = document.querySelector("#stock-search-autocomplete");
  let htmlContent = "";
  htmlContent += '<ul class="slc-search-suggest-items"></ul>';
  parent.setAttribute("aria-hidden", "false");
  parent.insertAdjacentHTML("beforeend", htmlContent);
  listContainer = parent.querySelector(".slc-search-suggest-items");
  list.stocks.forEach((data) => {
    const { stockName, stockCode, extract, extractWord, boldFrom, boldTo } = data;
    const applyBold = (text, start, end) => {
      let result = "";
      for (let i = 0; i < text.length; i++) {
        result += start <= i && i < end ? `<span class="slc-bold">${text[i]}</span>` : text[i];
      }
      return result;
    };
    let boldName = stockName;
    let boldCode = stockCode;
    let boldExtract = extractWord;
    let inputText = stockName;
    if (extract === "1") {
      boldName = applyBold(stockName, boldFrom, boldTo);
    } else if (extract === "2") {
      boldCode = applyBold(stockCode, boldFrom, boldTo);
    } else if (extract === "3") {
      boldExtract = applyBold(extractWord, boldFrom, boldTo);
    }
    const listItemHTML = `
        <li class="slc-search-suggest-item">
          <a data-stock="${stockCode}" tabindex="0" data-input-text="${inputText}">
            <span class="slc-header-suggest-left">
              <span class="slc-suggest-name">${boldName}</span>
              <span class="slc-suggest-code">${boldCode}</span>
            </span>
            <span class="slc-header-suggest-right">${boldExtract}</span>
          </a>
        </li>
        `;
    listContainer.insertAdjacentHTML("beforeend", listItemHTML);
    const lastAnchor = listContainer.lastElementChild.querySelector("a");
    lastAnchor.addEventListener("click", (e) => {
      e.preventDefault();
      const stockInput2 = document.querySelector("#brand-search-text");
      stockInput2.value = e.currentTarget.dataset.stock;
      stockInput2.focus();
      slcHeader.getOption();
      slcHeader.removeSuggest("#stock-search-autocomplete");
    });
  });
  let currentIndex = -1;
  const stockInput = document.querySelector("#brand-search-text");
  let originalInputText = stockInput.value;
  document.addEventListener("keydown", (e) => {
    if (slcHeader.searchSuggestArea.getAttribute("aria-hidden") === "false") {
      isKeyNavigating = e.key === "ArrowDown" || e.key === "ArrowUp" || e.key === "Enter" || e.key === "Tab";
      const suggestItems = listContainer.querySelectorAll(
        ".slc-search-suggest-item a"
      );
      if (e.key === "ArrowDown") {
        currentIndex++;
        if (currentIndex >= suggestItems.length) {
          currentIndex = -1;
          stockInput.focus();
          stockInput.value = originalInputText;
        } else {
          suggestItems[currentIndex].focus();
          const inputText = suggestItems[currentIndex].getAttribute("data-input-text");
          stockInput.value = inputText;
        }
        e.preventDefault();
      } else if (e.key === "ArrowUp") {
        currentIndex--;
        if (currentIndex !== -1) {
          if (currentIndex < -1) {
            currentIndex = suggestItems.length - 1;
          }
          suggestItems[currentIndex].focus();
          const inputText = suggestItems[currentIndex].getAttribute("data-input-text");
          stockInput.value = inputText;
        } else {
          stockInput.focus();
          stockInput.value = originalInputText;
        }
        e.preventDefault();
      } else if (e.key === "Enter") {
        if (currentIndex >= 0 && currentIndex < suggestItems.length) {
          suggestItems[currentIndex].click();
        }
      } else if (e.key === "Tab") {
        currentIndex = -1;
        slcHeader.searchSuggestArea.setAttribute("aria-hidden", true);
      }
    } else
      return;
  });
  document.addEventListener("keyup", (e) => {
    isKeyNavigating = !(e.key === "ArrowDown" || e.key === "ArrowUp" || e.key === "Enter" || e.key === "Tab");
  });
  slcHeader.removeRight();
};
slcHeader.brandSearchInput.addEventListener("blur", () => {
  if (!isKeyNavigating) {
    slcHeader.searchSuggestArea.setAttribute("aria-hidden", true);
  }
});
slcHeader.searchSuggestArea.addEventListener("mousedown", (e) => {
  e.preventDefault();
});
slcHeader.onSubmitStock = (data) => {
  const searchBox = document.querySelector(".slc-brand-search-box");
  searchBox.querySelector('[name="i_stock_sec"]').value = data.inputWord;
  searchBox.querySelector('[name="json_status"]').value = data.status;
  searchBox.querySelector('[name="qr_keyword"]').value = data.keyword;
  searchBox.querySelector('[name="qr_suggest"]').value = data.yosoku;
  searchBox.querySelector('[name="qr_sort"]').value = data.hyoji;
  let jsonContent = "";
  const stocks = data.stocks;
  for (let i = 0; i < stocks.length; i++) {
    for (let item in stocks[i]) {
      jsonContent += stocks[i][item] + ",";
    }
    if (i != stocks.length - 1) {
      jsonContent += "|";
    }
  }
  searchBox.querySelector('[name="json_content"]').value = jsonContent;
  const charset_save = document.charset;
  const cookieData = slcCommon.getCookieObject();
  const fromSiteUrl = (cookieData == null ? void 0 : cookieData.fromSite) || "https://www.sbisec.co.jp";
  document.charset = "shift_jis";
  const form = document.createElement("form");
  form.action = slcHeader.getMainSiteUrl(fromSiteUrl + "/ETGate/");
  form.method = "POST";
  form.acceptCharset = "Shift_JIS";
  const inputs = document.querySelectorAll(".slc-brand-search-box input");
  inputs.forEach((input) => {
    const clonedInput = input.cloneNode(true);
    clonedInput.style.display = "none";
    form.appendChild(clonedInput);
  });
  slcCommon.body.appendChild(form);
  form.submit();
  document.charset = charset_save;
};
(_b = (_a = document.querySelector(".slc-brand-search-box")) == null ? void 0 : _a.querySelector(".slc-search-button")) == null ? void 0 : _b.addEventListener("click", (event) => {
  const selectedCategory = slcHeader.brandSearchCategory.options[slcHeader.brandSearchCategory.selectedIndex].value;
  if (selectedCategory === "domestic") {
    slcHeader.getOption();
  } else {
    const input = event.target.closest(".slc-brand-search-box").querySelector(".slc-brand-search-box input").value;
    if (input) {
      if (selectedCategory === "foreign") {
        slcHeader.searchForeign(input);
      } else if (selectedCategory === "fund") {
        slcHeader.searchFund(input);
      }
    }
  }
});
slcHeader.brandSearchInput.addEventListener("keydown", (event) => {
  if (event.key == "Enter") {
    const selectedCategory = slcHeader.brandSearchCategory.options[slcHeader.brandSearchCategory.selectedIndex].value;
    if (selectedCategory === "domestic") {
      slcHeader.getOption();
    } else if (selectedCategory === "foreign") {
      slcHeader.searchForeign(event.target.value);
    } else if (selectedCategory === "fund") {
      slcHeader.searchFund(event.target.value);
    }
  }
});
slcHeader.closeSearchSuggestContent = () => {
  const searchSuggest = document.querySelector("#stock-search-autocomplete");
  searchSuggest.setAttribute("aria-hidden", true);
};
document.addEventListener("mousedown", (e) => {
  if (!e.target.closest("#stock-search-autocomplete")) {
    slcHeader.closeSearchSuggestContent();
  }
});
slcHeader.toggleLink = () => {
  const targetLinks = document.querySelectorAll("[data-customer-href]");
  targetLinks == null ? void 0 : targetLinks.forEach((targetLink) => {
    const customerHref = targetLink.dataset.customerHref;
    const isCustomer = slcCommon.getIsLogin();
    if (isCustomer) {
      targetLink.href = customerHref;
    }
  });
};
slcHeader.switchHeaderEventListener = () => {
  if (slcCommon.screenMdQuery.matches) {
    slcCommon.clearEventListener();
  }
};
slcCommon.screenMdQuery.addEventListener("change", () => {
  slcHeader.adjustDotsMenu();
  clearTimeout(slcHeader.headerTimer);
  slcHeader.headerTimer = setTimeout(
    slcHeader.switchHeaderEventListener(),
    100
  );
});
document.addEventListener("click", (e) => {
  if (!e.target.closest('[data-nav-item="dropdown"]') && slcCommon.screenMdQuery.matches) {
    slcCommon.closeHeaderDropdownContent();
  }
});
document.addEventListener("DOMContentLoaded", () => {
  slcHeader.toggleLogin();
  slcHeader.createDotsMenuItems();
  slcHeader.setDotsMenuAccordion();
  slcHeader.toggleLink();
  slcCommon.setUatUrl();
  slcHeader.setSiteSearchCallbacks();
});
slcHeader.setGlobalHamburger();
slcHeader.setDotsMenu();
slcHeader.switchHeaderEventListener();
slcHeader.switchHeaderDropdownContent();
slcHeader.searchSite();
slcHeader.toggleSearchDropdown();
