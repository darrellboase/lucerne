// Lucerne Herbicides PWA
// Loads dataset, supports search + filters, shows details, persists filter state

const state = {
  all: [],
  filtered: [],
  search: '',
  selectedTypes: new Set(),
  selectedPhyto: new Set(),
  selectedTiming: new Set(),
  selectedWeeds: new Set(),
};

const els = {
  list: document.getElementById('list'),
  search: document.getElementById('search'),
  filterBtn: document.getElementById('filterBtn'),
  filterDialog: document.getElementById('filterDialog'),
  filterTypes: document.getElementById('filterTypes'),
  filterPhyto: document.getElementById('filterPhyto'),
  filterTiming: document.getElementById('filterTiming'),
  filterWeeds: document.getElementById('filterWeeds'),
  weedSearch: document.getElementById('weedSearch'),
  resetFilters: document.getElementById('resetFilters'),
  applyFilters: document.getElementById('applyFilters'),
  activeFilters: document.getElementById('activeFilters'),
  detailDialog: document.getElementById('detailDialog'),
  detailContent: document.getElementById('detailContent'),
  closeDetail: document.getElementById('closeDetail'),
};

function uniqSorted(arr) {
  return Array.from(new Set(arr)).sort((a, b) => a.localeCompare(b));
}

function hydrateFilterOptions() {
  const types = uniqSorted(state.all.map(h => h.type));
  const phyto = uniqSorted(state.all.map(h => h.phytoxicity));
  const timing = uniqSorted(state.all.flatMap(h => h.applicationTiming));
  const weeds = uniqSorted(state.all.flatMap(h => h.weedsControlled));

  const makeChecklist = (container, values, selectedSet) => {
    container.innerHTML = '';
    values.forEach(v => {
      const id = `${container.id}-${v}`;
      const item = document.createElement('label');
      item.className = 'item';
      item.innerHTML = `<input type="checkbox" id="${id}" ${selectedSet.has(v) ? 'checked' : ''}/> <span>${v}</span>`;
      item.querySelector('input').addEventListener('change', (e) => {
        if (e.target.checked) selectedSet.add(v); else selectedSet.delete(v);
      });
      container.appendChild(item);
    });
  };

  makeChecklist(els.filterTypes, types, state.selectedTypes);
  makeChecklist(els.filterPhyto, phyto, state.selectedPhyto);
  makeChecklist(els.filterTiming, timing, state.selectedTiming);

  // Weeds with optional search
  const renderWeeds = (query = '') => {
    const filtered = weeds.filter(w => w.toLowerCase().includes(query.trim().toLowerCase()));
    makeChecklist(els.filterWeeds, filtered, state.selectedWeeds);
  };
  renderWeeds();
  els.weedSearch.oninput = () => renderWeeds(els.weedSearch.value);
}

function applyFilters() {
  const text = state.search.trim().toLowerCase();
  state.filtered = state.all.filter(h => {
    if (text) {
      const matchText = (
        h.name.toLowerCase().includes(text) ||
        h.commonName.toLowerCase().includes(text) ||
        h.weedsControlled.some(w => w.toLowerCase().includes(text))
      );
      if (!matchText) return false;
    }

    if (state.selectedTypes.size && !state.selectedTypes.has(h.type)) return false;
    if (state.selectedPhyto.size && !state.selectedPhyto.has(h.phytoxicity)) return false;
    if (state.selectedTiming.size) {
      const overlap = h.applicationTiming.some(t => state.selectedTiming.has(t));
      if (!overlap) return false;
    }
    if (state.selectedWeeds.size) {
      const controlsAll = Array.from(state.selectedWeeds).every(w => h.weedsControlled.includes(w));
      if (!controlsAll) return false;
    }
    return true;
  });
  renderList();
  renderActiveFilterChips();
  saveFilterState();
}

function renderActiveFilterChips() {
  const chips = [];
  const addChip = (label, onRemove) => {
    const chip = document.createElement('span');
    chip.className = 'chip';
    chip.innerHTML = `${label} <button aria-label="Remove">✕</button>`;
    chip.querySelector('button').onclick = onRemove;
    chips.push(chip);
  };

  state.selectedTypes.forEach(v => addChip(v, () => { state.selectedTypes.delete(v); applyFilters(); hydrateFilterOptions(); }));
  state.selectedPhyto.forEach(v => addChip(v, () => { state.selectedPhyto.delete(v); applyFilters(); hydrateFilterOptions(); }));
  state.selectedTiming.forEach(v => addChip(v, () => { state.selectedTiming.delete(v); applyFilters(); hydrateFilterOptions(); }));
  state.selectedWeeds.forEach(v => addChip(v, () => { state.selectedWeeds.delete(v); applyFilters(); hydrateFilterOptions(); }));

  els.activeFilters.innerHTML = '';
  chips.forEach(c => els.activeFilters.appendChild(c));
}

function renderList() {
  els.list.innerHTML = '';
  if (!state.filtered.length) {
    const empty = document.createElement('div');
    empty.className = 'card';
    empty.textContent = 'No herbicides match your filters.';
    els.list.appendChild(empty);
    return;
  }
  state.filtered.forEach(h => {
    const card = document.createElement('article');
    card.className = 'card';
    card.innerHTML = `
      <h3>${h.name}</h3>
      <div class="sub">${h.commonName}</div>
      <div class="tags">${h.weedsControlled.slice(0,3).map(w => `<span class="tag">${w}</span>`).join('')}
        ${h.weedsControlled.length>3 ? `<span class="tag">+${h.weedsControlled.length-3} more</span>`:''}
      </div>
    `;
    card.addEventListener('click', () => openDetail(h));
    els.list.appendChild(card);
  });
}

function openDetail(h) {
  const section = (title, content) => `<section class="detail-section"><h3>${title}</h3>${content}</section>`;
  const rows = (items) => items.map(i => `<li>${i}</li>`).join('');
  els.detailContent.innerHTML = `
    <h2>${h.name}</h2>
    <div class="muted">${h.commonName}</div>
    ${section('Quick Info', `
      <div class="detail-row"><span>Type</span><strong>${h.type}</strong></div>
      <div class="detail-row"><span>Application rate</span><strong>${h.applicationRate}</strong></div>
      <div class="detail-row"><span>Rainfastness</span><strong>${h.rainfastness}</strong></div>
      <div class="detail-row"><span>Grazing restriction</span><strong>${h.grazingRestriction}</strong></div>
    `)}
    ${section('Active ingredients', `<ul>${rows(h.activeIngredients)}</ul>`)}
    ${section('Application timing', `<ul>${rows(h.applicationTiming)}</ul>`)}
    ${section('Weeds controlled', `<div class="tags">${h.weedsControlled.map(w => `<span class="tag">${w}</span>`).join('')}</div>`)}
    ${h.notes ? section('Notes', `<p>${h.notes}</p>`) : ''}
    ${h.safetyInformation ? section('Safety', `<p>${h.safetyInformation}</p>`) : ''}
  `;
  els.detailDialog.showModal();
}

function saveFilterState() {
  try {
    const data = {
      search: state.search,
      types: Array.from(state.selectedTypes),
      phyto: Array.from(state.selectedPhyto),
      timing: Array.from(state.selectedTiming),
      weeds: Array.from(state.selectedWeeds),
    };
    localStorage.setItem('filters', JSON.stringify(data));
  } catch {}
}

function restoreFilterState() {
  try {
    const raw = localStorage.getItem('filters');
    if (!raw) return;
    const data = JSON.parse(raw);
    state.search = data.search || '';
    state.selectedTypes = new Set(data.types || []);
    state.selectedPhyto = new Set(data.phyto || []);
    state.selectedTiming = new Set(data.timing || []);
    state.selectedWeeds = new Set(data.weeds || []);
    els.search.value = state.search;
  } catch {}
}

async function loadData() {
  // Use the PWA copy of the dataset
  const res = await fetch('./data/herbicides.json');
  const items = await res.json();
  state.all = items;
  state.filtered = items;
}

function wireUI() {
  els.search.addEventListener('input', () => { state.search = els.search.value; applyFilters(); });
  els.filterBtn.addEventListener('click', () => els.filterDialog.showModal());
  els.applyFilters.addEventListener('click', () => { applyFilters(); els.filterDialog.close(); });
  els.resetFilters.addEventListener('click', () => {
    state.selectedTypes.clear();
    state.selectedPhyto.clear();
    state.selectedTiming.clear();
    state.selectedWeeds.clear();
    els.weedSearch.value = '';
    hydrateFilterOptions();
    applyFilters();
  });
  els.closeDetail.addEventListener('click', () => els.detailDialog.close());
}

(async function init() {
  restoreFilterState();
  await loadData();
  hydrateFilterOptions();
  applyFilters();
  wireUI();
})();
