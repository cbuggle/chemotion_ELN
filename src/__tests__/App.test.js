test("test environment supports DOM assertions", () => {
  document.body.innerHTML = "<main>Reaction process editor</main>";

  expect(document.querySelector("main")).toHaveTextContent("Reaction process editor");
});
