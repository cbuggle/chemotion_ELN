import { render, screen, waitFor } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { MemoryRouter, useLocation } from "react-router-dom";

import MainHeader from "../../../components/layout/MainHeader";

const mockIndexOf = jest.fn();
const mockCollectionSelectOptions = jest.fn();
const mockGeDefaultConditions = jest.fn();
const mockSignOut = jest.fn();

jest.mock("../../../fetchers/ReactionsFetcher", () => ({
  useReactionsFetcher: () => ({
    indexOf: mockIndexOf,
    collectionSelectOptions: mockCollectionSelectOptions,
    geDefaultConditions: mockGeDefaultConditions,
  }),
}));

jest.mock("../../../fetchers/AuthenticationFetcher", () => ({
  useAuthenticationFetcher: () => ({
    signOut: mockSignOut,
  }),
}));

jest.mock("../../../components/utilities/DefaultConditionsFormModal", () => () => null);

jest.mock("@fortawesome/react-fontawesome", () => ({
  FontAwesomeIcon: () => null,
}));

const LocationProbe = () => {
  const location = useLocation();

  return <div data-testid="location">{location.pathname}</div>;
};

const renderMainHeader = () => render(
  <MemoryRouter initialEntries={["/reactions/2"]}>
    <MainHeader />
    <LocationProbe />
  </MemoryRouter>
);

describe("reaction 2 navbar sample links", () => {
  beforeEach(() => {
    jest.clearAllMocks();
    localStorage.clear();
    localStorage.setItem("username", "fixture.user@example.test");
    localStorage.setItem("bearer_auth_token", "fixture-token");

    mockCollectionSelectOptions.mockResolvedValue({
      collection_select_options: [{ value: "fixture-collection", label: "Fixture Collection" }],
    });
    mockGeDefaultConditions.mockResolvedValue({
      default_conditions: {
        global: {},
        user: {},
        select_options: {},
      },
    });
    mockIndexOf.mockImplementation((model) => {
      if (model === "samples") {
        return Promise.resolve({
          samples: [
            { id: 1, external_label: "CU1-Joshua" },
            { id: 2, external_label: "CU1-Elden" },
          ],
        });
      }

      return Promise.resolve({ reactions: [] });
    });
  });

  test("renders direct links for indexed samples", async () => {
    renderMainHeader();

    const sample2Link = (await screen.findByText("2: CU1-Elden")).closest("a");

    expect(mockIndexOf).toHaveBeenCalledWith("samples");
    expect(sample2Link).toHaveAttribute("href", "/samples/2");
    expect(screen.getByText("1: CU1-Joshua").closest("a")).toHaveAttribute(
      "href",
      "/samples/1"
    );
  });

  test("navigates to the first matching sample link with Enter", async () => {
    renderMainHeader();

    await waitFor(() => expect(mockIndexOf).toHaveBeenCalledWith("samples"));
    userEvent.type(screen.getByPlaceholderText("Samples"), "Elden{enter}");

    await waitFor(() => {
      expect(screen.getByTestId("location")).toHaveTextContent("/samples/2");
    });
  });
});
