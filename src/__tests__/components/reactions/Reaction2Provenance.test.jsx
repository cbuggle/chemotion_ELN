import { fireEvent, render, screen, waitFor } from "@testing-library/react";
import userEvent from "@testing-library/user-event";

import {
  mockUpdateProvenance,
  reaction2Process,
  resetReaction2Mocks,
} from "../../../testSupport/reaction2TestHelpers";
import ProvenanceFormButton from "../../../components/reactions/navbar/ProvenanceFormButton";

jest.mock("react-datetime-picker", () => ({
  __esModule: true,
  default: ({ value, onChange }) => (
    <input
      aria-label="Reaction starts at"
      onChange={(event) => onChange(new Date(event.target.value))}
      value={value instanceof Date ? value.toISOString().slice(0, 19) : ""}
    />
  ),
}));

const renderProvenanceForm = (provenance = reaction2Process.provenance) => render(
  <ProvenanceFormButton provenance={provenance} />
);

const openProvenanceForm = () => {
  userEvent.click(screen.getByRole("button", { name: "pen" }));
};

const replaceInputValue = (input, value) => {
  userEvent.clear(input);
  userEvent.type(input, value);
};

const replaceDateValue = (input, value) => {
  fireEvent.change(input, { target: { value } });
};

describe("reaction 2 provenance", () => {
  beforeEach(() => {
    resetReaction2Mocks();
  });

  test("sets and saves the reaction provenance metadata", async () => {
    renderProvenanceForm({
      ...reaction2Process.provenance,
      name: "",
      city: "",
      doi: "",
      patent: "",
      publication_url: "",
      orcid: "",
      organization: "",
    });

    openProvenanceForm();

    replaceDateValue(screen.getByLabelText("Reaction starts at"), "2026-07-14T09:30:00");
    replaceInputValue(screen.getByPlaceholderText("Reaction Name"), "Fixture esterification run");
    replaceInputValue(screen.getByPlaceholderText("Place (City)"), "Karlsruhe");
    replaceInputValue(screen.getByPlaceholderText("DOI"), "10.1234/fixture.provenance");
    replaceInputValue(screen.getByPlaceholderText("Patent"), "WO2026-FIXTURE");
    replaceInputValue(screen.getByPlaceholderText("Publication URL"), "https://example.test/publication");
    replaceInputValue(screen.getByPlaceholderText("Orcid"), "0000-0002-1825-0097");
    replaceInputValue(screen.getByPlaceholderText("Organisation"), "Fixture Institute");
    userEvent.click(screen.getByRole("button", { name: "Save" }));

    await waitFor(() => expect(mockUpdateProvenance).toHaveBeenCalledTimes(1));
    expect(mockUpdateProvenance).toHaveBeenCalledWith(
      expect.objectContaining({
        reaction_process_id: reaction2Process.id,
        starts_at: new Date("2026-07-14T09:30:00"),
        name: "Fixture esterification run",
        city: "Karlsruhe",
        doi: "10.1234/fixture.provenance",
        patent: "WO2026-FIXTURE",
        publication_url: "https://example.test/publication",
        username: reaction2Process.provenance.username,
        email: reaction2Process.provenance.email,
        orcid: "0000-0002-1825-0097",
        organization: "Fixture Institute",
      })
    );
  });

  test("edits existing provenance values and keeps user identity fields read only", async () => {
    renderProvenanceForm({
      ...reaction2Process.provenance,
      name: "Original run",
      city: "Berlin",
      doi: "10.1000/original",
      patent: "EP-ORIGINAL",
      publication_url: "https://example.test/original",
      orcid: "0000-0001-1111-1111",
      organization: "Original Institute",
    });

    openProvenanceForm();

    expect(screen.getByPlaceholderText("Conducted by")).toBeDisabled();
    expect(screen.getByPlaceholderText("Email")).toBeDisabled();

    replaceInputValue(screen.getByPlaceholderText("Reaction Name"), "Edited oxidation run");
    replaceInputValue(screen.getByPlaceholderText("Place (City)"), "Heidelberg");
    replaceInputValue(screen.getByPlaceholderText("DOI"), "10.5678/edited.provenance");
    replaceInputValue(screen.getByPlaceholderText("Patent"), "EP-EDITED");
    replaceInputValue(screen.getByPlaceholderText("Publication URL"), "https://example.test/edited");
    replaceInputValue(screen.getByPlaceholderText("Orcid"), "0000-0003-3333-3333");
    replaceInputValue(screen.getByPlaceholderText("Organisation"), "Edited Institute");
    userEvent.click(screen.getByRole("button", { name: "Save" }));

    await waitFor(() => expect(mockUpdateProvenance).toHaveBeenCalledTimes(1));
    expect(mockUpdateProvenance).toHaveBeenCalledWith(
      expect.objectContaining({
        reaction_process_id: reaction2Process.id,
        name: "Edited oxidation run",
        city: "Heidelberg",
        doi: "10.5678/edited.provenance",
        patent: "EP-EDITED",
        publication_url: "https://example.test/edited",
        username: reaction2Process.provenance.username,
        email: reaction2Process.provenance.email,
        orcid: "0000-0003-3333-3333",
        organization: "Edited Institute",
      })
    );
  });
});
