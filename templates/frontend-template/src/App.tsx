import { BrowserRouter, Routes, Route } from "react-router-dom";
import PageWrapper from "./Pages/PageWrapper";
import { Provider } from "react-redux";
import { store } from "./Redux/Store";

import MainPage from "./Pages/Main/MainPage";
import Page404 from "./Pages/Main/Page404";

function App() {
  return (
    <Provider store={store}>
      <BrowserRouter>
        <Routes>
          <Route element={<PageWrapper />}>
            <Route path="/" element={<MainPage />} />
            <Route path="*" element={<Page404 />} />
          </Route>
        </Routes>
      </BrowserRouter>
    </Provider>
  );
}

export default App;
