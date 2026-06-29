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
  <MemoryRouter initialEntries={["/reactions"]}>
    <MainHeader />
    <LocationProbe />
  </MemoryRouter>
);

describe("reaction 2 navbar reaction links", () => {
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
      if (model === "reactions") {
        return Promise.resolve({
          reactions: [
            { id: 1, short_label: "CU1-R1" },
            { id: 2, short_label: "CU1-R2" },
          ],
        });
      }

      return Promise.resolve({ samples: [] });
    });
  });

  test("renders direct links for indexed reactions", async () => {
    renderMainHeader();

    const reaction2Link = (await screen.findByText("2: CU1-R2")).closest("a");

    expect(mockIndexOf).toHaveBeenCalledWith("reactions");
    expect(reaction2Link).toHaveAttribute("href", "/reactions/2");
    expect(screen.getByText("1: CU1-R1").closest("a")).toHaveAttribute(
      "href",
      "/reactions/1"
    );
  });

  test("navigates to the first matching reaction link with Enter", async () => {
    renderMainHeader();

    await waitFor(() => expect(mockIndexOf).toHaveBeenCalledWith("reactions"));
    userEvent.type(screen.getByPlaceholderText("Reactions"), "R2{enter}");

    await waitFor(() => {
      expect(screen.getByTestId("location")).toHaveTextContent("/reactions/2");
    });
  });
});
