# VIDEO DEMO NOTE
My device have problem with the audio, i could not record it currently. However, if i can reupload the video, ill try submitting with voice narration using other device recorder.

# Product Catalog (Flutter)

A small product catalog app built against the free [DummyJSON](https://dummyjson.com) API.

## Running it

```bash
flutter pub get
flutter run
```

Run the unit test:

```bash
flutter test
```

## Features implemented

- **Product list** — title, thumbnail, and price per product (`ProductListTile`).
- **Pagination** — `ListView` with a `ScrollController` that fetches the next page
  (`?limit=20&skip=N`) when the user scrolls within 300px of the bottom. A footer row
  shows a spinner while loading, an inline retry row if a page fails to load, or
  "You've reached the end" once `total` items have been loaded.
- **Product detail** — full description, price, rating, brand, and an image carousel
  (`PageView`) built from the `images` array (falling back to the thumbnail).
- **States** — `ProductListState` (`loading`, `error`, `empty`, `success`) is explicit
  provider state, not inferred from nulls, so the list screen always shows exactly one
  of: a spinner, an error view with a **Retry** button, an empty-state message, or the
  list. The detail screen mirrors this via `FutureBuilder`.
- **Search** — a debounced (500ms) search box that calls the **search endpoint**
  (`/products/search?q=`), not client-side filtering. Reasoning: DummyJSON's catalog
  is only ~194 products, which is small either way, but hitting the real search
  endpoint (a) exercises the same pagination path (`skip`/`limit`/`total` all still
  apply to search results), (b) matches how a real backend-driven catalog would behave
  once the dataset is too large to ship to the client, and (c) avoids keeping the full
  product list resident in memory just to filter it. The 500ms debounce (via a `Timer`
  in the search field's `State`, cancelled/reset on every keystroke) avoids firing a
  request per keystroke.
- **Code organization** — 3 layers:
  - `data/` — `models` (plain data classes + `fromJson`), `services` (`ProductApiService`,
    the only class that touches `http`/JSON), `repositories` (`ProductRepository`, the
    seam the presentation layer depends on).
  - `presentation/providers` — `ProductListProvider`, a `ChangeNotifier` holding all
    list/pagination/search state and talking only to `ProductRepository`.
  - `presentation/screens` + `presentation/widgets` — UI only; no networking code.

## Bonus items implemented

- **Pull-to-refresh** on the list (`RefreshIndicator` → `provider.refresh()`).
- **Image loading placeholder / error handling** — `NetworkThumbnail` shows a spinner
  while an image loads and a fallback icon if it fails or the URL is empty, used for
  both list thumbnails and the detail carousel.
- **Unit tests** (`test/product_repository_test.dart`) — cover successful list
  parsing, that search hits `/products/search` with the right `q` param, that a
  non-2xx response throws `ProductApiException`, and detail parsing. Uses
  `package:http/testing.dart`'s `MockClient`, so no real network calls or extra test
  dependencies are needed.

## Notes / trade-offs

- State management is a single `ChangeNotifier` + `provider` rather than a larger
  framework (Bloc/Riverpod) — appropriate for the scope of this app.
- "Load more" failures don't clear the already-loaded list; only the footer shows an
  error, so a flaky page fetch never loses what's already on screen.
- The detail screen's pull-to-refresh is a no-op placeholder (a single product rarely
  needs refreshing mid-view); it's there mainly for scroll-physics consistency.

# AI USAGE

- API integration 
- Finalization of the app (clean structure/logic, data and presentation files)
- Product repository test