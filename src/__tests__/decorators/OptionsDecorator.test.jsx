import OptionsDecorator from "../../decorators/OptionsDecorator";

const options = [
  { value: 1, label: "One" },
  { value: "2", label: "Two" },
  { value: "three", label: "Three" }
];

describe("OptionsDecorator", () => {
  test("finds options using loose value comparison", () => {
    expect(OptionsDecorator.optionForValue("1", options)).toEqual({ value: 1, label: "One" });
    expect(OptionsDecorator.optionForValue(2, options)).toEqual({ value: "2", label: "Two" });
  });

  test("maps values to labels", () => {
    expect(OptionsDecorator.valueToLabel("three", options)).toBe("Three");
    expect(OptionsDecorator.valuesToLabel([1, "2"], options)).toBe("One, Two");
  });

  test("filters options for an array of values", () => {
    expect(OptionsDecorator.optionsForValues(["2", "three"], options)).toEqual([
      { value: "2", label: "Two" },
      { value: "three", label: "Three" }
    ]);
  });

  test("creates unavailable fallback options", () => {
    expect(OptionsDecorator.createUnavailableOption("missing")).toEqual({
      value: "missing",
      label: "missing",
      unavailable: true
    });

    expect(OptionsDecorator.inclusiveOptionForValue("missing", options)).toEqual({
      value: "missing",
      label: "missing",
      unavailable: true
    });
  });

  test("appends missing values to option lists", () => {
    expect(OptionsDecorator.appendValuesToOptions(["three", "missing"], options)).toEqual([
      ...options,
      { value: "missing", label: "missing", unavailable: true }
    ]);

    expect(OptionsDecorator.appendValueToOptions("missing", options)).toEqual([
      ...options,
      { value: "missing", label: "missing", unavailable: true }
    ]);
  });

  test("marks missing current options as unavailable while keeping provided options", () => {
    const currentOptions = [{ value: "missing", label: "Missing" }];

    expect(OptionsDecorator.inclusiveOptions(currentOptions, options)).toEqual([
      ...options,
      { value: "missing", label: "Missing", unavailable: true }
    ]);
  });
});
