import { createPages } from "waku";
import * as Infinite from "./pages/infinite.jsx";
import * as Overview from "./pages/Overview.jsx";

const pages = createPages(async ({ createPage }) => {
  createPage({
    render: "static",
    path: "/",
    component: Infinite.default
  });

  createPage({
    render: "dynamic",
    path: "/overview",
    component: Overview.default
  });
});

export default pages;
