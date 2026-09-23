// Sort and filter the cards of a section page (education, awards, ...).
// The starting order comes from Jekyll (see _layouts/list-post.html) ; here the
// cards are reordered and hidden in the browser, without reloading the page.
(function () {
  const container = document.querySelector(".cards-container");
  const sortSelect = document.getElementById("cards-sort");
  const filterInput = document.getElementById("cards-filter");
  const noneMessage = document.getElementById("cards-none");
  if (!container || !sortSelect || !filterInput) return;

  const cards = Array.from(container.children);

  // "maitrise" must find "maîtrise" : accents are removed on both sides.
  const fold = (text) =>
    text.toLowerCase().normalize("NFD").replace(/\p{Diacritic}/gu, "");

  function sortCards(value) {
    const [key, direction] = value.split("-");
    const sign = direction === "asc" ? 1 : -1;
    cards
      .slice()
      .sort((a, b) => sign * a.dataset[key].localeCompare(b.dataset[key]))
      .forEach((card) => container.appendChild(card));
  }

  function filterCards(query) {
    const needle = fold(query.trim());
    let shown = 0;
    cards.forEach((card) => {
      const match = needle === "" || fold(card.dataset.search).includes(needle);
      card.hidden = !match;
      if (match) shown += 1;
    });
    if (noneMessage) noneMessage.hidden = shown !== 0;
  }

  sortSelect.addEventListener("change", () => sortCards(sortSelect.value));
  filterInput.addEventListener("input", () => filterCards(filterInput.value));

  // The browser may restore the fields after a back navigation.
  if (sortSelect.value !== "date-desc") sortCards(sortSelect.value);
  if (filterInput.value !== "") filterCards(filterInput.value);
})();
