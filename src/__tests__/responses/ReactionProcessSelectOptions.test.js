import fs from "fs";
import path from "path";

const fixturePath = path.resolve(process.cwd(), "src/__tests__/fixtures/reaction_1_reaction_process.json");
const reactionProcessFixture = JSON.parse(fs.readFileSync(fixturePath, "utf8"));
const reactionProcess = reactionProcessFixture.response.json.reaction_process;
const processStep = reactionProcess.reaction_process_steps[0];

describe("/reactions/1 reaction_process select_options response contract", () => {
  test("includes process-level select_options", () => {
    expect(reactionProcess).toHaveProperty("select_options");
    expect(reactionProcess.select_options).toEqual(expect.any(Object));
    expect(Object.keys(reactionProcess.select_options)).toEqual(
      expect.arrayContaining([
        "samples_preparations",
        "vessel_preparations",
        "step_name_suggestions",
        "materials",
        "equipment",
        "FORMS",
        "ontologies",
        "automation_control"
      ])
    );
  });

  test("includes step-level select_options", () => {
    expect(processStep).toHaveProperty("select_options");
    expect(processStep.select_options).toEqual(expect.any(Object));
    expect(Object.keys(processStep.select_options)).toEqual(
      expect.arrayContaining(["added_materials", "mounted_equipment", "saved_samples", "FORMS"])
    );
  });
});
