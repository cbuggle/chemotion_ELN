const reaction2Fixture = require("../fixtures/reaction_2_reaction_process.json");

const reactionProcess = reaction2Fixture.response.json.reaction_process;

const expectedKeys = [
  ["id", "string"],
  ["short_label", "string"],
  ["sample_setup", "object"],
  ["initial_conditions", "object"],
  ["reaction_process_steps", "array"],
  ["samples_preparations", "array"],
  ["reaction_process_vessels", "array"],
  ["provenance", "object"],
  ["sample", "nullable"],
  ["reaction_process_vessel", "nullable"],
  ["reaction_svg_file", "string"],
  ["reaction_default_conditions", "object"],
  ["user_reaction_default_conditions", "object"],
  ["select_options", "object"],
  ["initial_sample_transfers", "array"],
];

const valueHasType = (value, expectedType) => {
  if (expectedType === "array") return Array.isArray(value);
  if (expectedType === "nullable") return value === null || typeof value === "object";

  return typeof value === expectedType && value !== null && !Array.isArray(value);
};

describe("/reactions/2 response keys", () => {
  test("wraps the response json in a reaction_process key", () => {
    expect(reaction2Fixture.response.status).toBe(200);
    expect(reaction2Fixture.response.json).toHaveProperty("reaction_process");
  });

  test("does not drift from the expected top-level reaction process keys", () => {
    expect(Object.keys(reactionProcess).sort()).toEqual(
      expectedKeys.map(([key]) => key).sort()
    );
  });

  test.each(expectedKeys)("includes %s with the expected %s shape", (key, expectedType) => {
    expect(reactionProcess).toHaveProperty(key);
    expect(valueHasType(reactionProcess[key], expectedType)).toBe(true);
  });
});
