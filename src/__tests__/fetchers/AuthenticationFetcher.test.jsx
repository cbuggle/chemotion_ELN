import fs from "fs";
import path from "path";

import { act } from "react";
import { createRoot } from "react-dom/client";
import { waitFor } from "@testing-library/react";

import NotificationContext from "../../contexts/NotificationContext";
import { useAuthenticationFetcher } from "../../fetchers/AuthenticationFetcher";

const mockNavigate = jest.fn();

jest.mock("react-router-dom", () => ({
  ...jest.requireActual("react-router-dom"),
  useNavigate: () => mockNavigate
}));

jest.mock("../../constants", () => ({
  apiBasePath: "http://localhost:3000/api/v1/reaction_process_editor",
  afterSignInPath: "/reactions",
  afterSignOutPath: "/",
  generalErrorRedirectPath: "/reactions",
  unauthorizedRedirectPath: "/"
}));

const fixturePath = path.resolve(process.cwd(), "src/__tests__/fixtures/sign_in.json");
const signInFixture = JSON.parse(fs.readFileSync(fixturePath, "utf8"));

const credentials = {
  username: "random.user@example.test",
  password: "random-password-123"
};

const responseFromFixture = () => responseFrom({
  status: signInFixture.response.status,
  statusText: signInFixture.response.statusText,
  headers: signInFixture.response.headers
});

const responseFrom = ({ status, statusText, headers = {} }) => ({
  status,
  statusText,
  headers: {
    get: (name) => headers[name] || headers[name.toLowerCase()] || null
  }
});

const SignInButton = ({ credentials }) => {
  const authenticationFetcher = useAuthenticationFetcher();

  return (
    <button type="button" onClick={() => authenticationFetcher.signIn(credentials)}>
      Sign in
    </button>
  );
};

const renderSignInButton = ({ addNotification = jest.fn(), signInCredentials = credentials } = {}) => {
  const container = document.createElement("div");
  document.body.appendChild(container);
  const root = createRoot(container);

  act(() => {
    root.render(
      <NotificationContext.Provider value={{ addNotification }}>
        <SignInButton credentials={signInCredentials} />
      </NotificationContext.Provider>
    );
  });

  return {
    addNotification,
    button: container.querySelector("button"),
    unmount: () => {
      act(() => root.unmount());
      container.remove();
    }
  };
};

describe("useAuthenticationFetcher signIn", () => {
  let mountedComponents;

  beforeEach(() => {
    jest.clearAllMocks();
    localStorage.clear();
    global.fetch = jest.fn();
    mountedComponents = [];
  });

  afterEach(() => {
    mountedComponents.forEach((component) => component.unmount());
  });

  test("posts credentials to the configured sign-in endpoint", async () => {
    global.fetch.mockResolvedValue(responseFromFixture());
    const component = renderSignInButton();
    mountedComponents.push(component);

    await act(async () => component.button.click());

    await waitFor(() => expect(global.fetch).toHaveBeenCalledTimes(1));
    expect(global.fetch).toHaveBeenCalledWith(
      "http://localhost:3000/api/v1/reaction_process_editor/sign_in",
      {
        method: "POST",
        headers: {
          Accept: "application/json",
          "Content-Type": "application/json",
          "Access-Control-Allow-Origin": "*"
        },
        body: JSON.stringify({
          user: {
            login: credentials.username,
            password: credentials.password
          }
        })
      }
    );
  });

  test("stores the signed-in user and bearer token from the fixture response", async () => {
    const component = renderSignInButton();
    mountedComponents.push(component);
    global.fetch.mockResolvedValue(responseFromFixture());

    await act(async () => component.button.click());

    const expectedToken = signInFixture.response.headers.authorization.split("Bearer ")[1];

    await waitFor(() => {
      expect(localStorage.getItem("username")).toBe(credentials.username);
      expect(localStorage.getItem("bearer_auth_token")).toBe(expectedToken);
    });
    expect(mockNavigate).toHaveBeenCalledWith("/reactions");
    expect(component.addNotification).toHaveBeenCalledWith({
      title: "Success",
      message: "Logged in as random.user@example.test.",
      type: "success"
    });
  });

  test("clears the session and warns on unauthorized credentials", async () => {
    localStorage.setItem("username", "existing.user@example.test");
    localStorage.setItem("bearer_auth_token", "existing-token");
    global.fetch.mockResolvedValue(responseFrom({ status: 401, statusText: "Unauthorized" }));
    const component = renderSignInButton();
    mountedComponents.push(component);

    await act(async () => component.button.click());

    await waitFor(() => {
      expect(localStorage.getItem("username")).toBeNull();
      expect(localStorage.getItem("bearer_auth_token")).toBeNull();
    });
    expect(mockNavigate).toHaveBeenCalledWith("/");
    expect(component.addNotification).toHaveBeenCalledWith({
      title: "Username or Password wrong.",
      message: "Please check your spelling.",
      type: "warning"
    });
  });

  test("clears the session and reports unexpected sign-in errors", async () => {
    localStorage.setItem("username", "existing.user@example.test");
    localStorage.setItem("bearer_auth_token", "existing-token");
    global.fetch.mockResolvedValue(responseFrom({ status: 500, statusText: "Internal Server Error" }));
    const component = renderSignInButton();
    mountedComponents.push(component);

    await act(async () => component.button.click());

    await waitFor(() => {
      expect(localStorage.getItem("username")).toBeNull();
      expect(localStorage.getItem("bearer_auth_token")).toBeNull();
    });
    expect(mockNavigate).toHaveBeenCalledWith("/");
    expect(component.addNotification).toHaveBeenCalledWith({
      title: "Unknown Error: 500",
      message: "Internal Server Error",
      type: "error"
    });
  });
});
