import { createPages } from "waku";
import * as Infinite from "./pages/infinite.jsx";

const pages = createPages(async ({ createPage }) => {
  createPage({
    render: "static",
    path: "/",
    component: Infinite.default
  });
});

export default pages;
