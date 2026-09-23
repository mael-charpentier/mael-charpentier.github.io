// Nav hamburgerburger selections
let burger = document.getElementById("burger-menu");
let ul = document.getElementById("menu");
let nav = document.getElementById("navigator");

// Scroll to top selection
let scrollUp = document.getElementById("scroll-up");

// Select nav links
let navLink = document.querySelectorAll(".nav-link");

let showBurgerMenu = false;
let burgerMenuBar = document.getElementById("burger-bars");
let burgerMenuClose = document.getElementById("burger-close");

// Hamburger menu function
burger.addEventListener("click", () => {
  showBurgerMenu = !showBurgerMenu;
  showBurger(showBurgerMenu);
});

// Close hamburger menu when a link is clicked
function closeBurger() {
  if (showBurgerMenu) {
    showBurgerMenu = !showBurgerMenu;
    showBurger(showBurgerMenu);
  }
}

// scroll to top functionality
scrollUp.addEventListener("click", () => {
  window.scrollTo({
    top: 0,
    left: 0,
    behavior: "smooth",
  });
});


function reportWindowSize() {
  if (window.innerWidth > 720) {
    showBurger(true);
  } else {
    showBurger(false);
  }
}

function showBurger(bool) {
  burger.setAttribute("aria-expanded", bool);
  if (bool) {
    //ul.classList.toggle("show");
    ul.style.display = 'flex';
    burgerMenuBar.style.display = 'none';
    burgerMenuClose.style.display = 'block';
  } else {
    //ul.classList.remove("show");
    ul.style.display = 'none';
    burgerMenuBar.style.display = 'block';
    burgerMenuClose.style.display = 'none';
  }
}

window.onresize = reportWindowSize;


const BIRTH_DATE = new Date(2002, 11, 31); // 31 of december 2002

function getMyAge(dateNew = new Date()) {
  let dateOld = BIRTH_DATE;
  let yNew = dateNew.getFullYear();
  let mNew = dateNew.getMonth();
  let dNew = dateNew.getDate();
  let yOld = dateOld.getFullYear();
  let mOld = dateOld.getMonth();
  let dOld = dateOld.getDate();
  let diff = yNew - yOld;
  if (mOld > mNew || (mOld == mNew && dOld > dNew)){
    return diff-1;
  }
  return diff;
}

const ageElement = document.getElementById("age");
if (ageElement) {
  ageElement.innerText = getMyAge();
}