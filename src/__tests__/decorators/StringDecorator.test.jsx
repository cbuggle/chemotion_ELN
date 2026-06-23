import StringDecorator from "../../decorators/StringDecorator";

describe("StringDecorator", () => {
  test("converts constants and underscored strings to label spelling", () => {
    expect(StringDecorator.toLabelSpelling("ADD_SAMPLE")).toBe("Add Sample");
    expect(StringDecorator.toLabelSpelling("gas exchange")).toBe("Gas Exchange");
  });

  test("returns undefined for empty input", () => {
    expect(StringDecorator.toLabelSpelling()).toBeUndefined();
  });

  test("wraps strings in brackets", () => {
    expect(StringDecorator.brackets("step")).toBe("(step)");
  });
});
