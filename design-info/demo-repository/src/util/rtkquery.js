// api.js (RTK Query for getUserProfile)
import { createApi, fetchBaseQuery } from "@reduxjs/toolkit/query/react";

export const authApi = createApi({
  reducerPath: "authApi",
  baseQuery: fetchBaseQuery({
    baseUrl: "https://app.duoshaokankan.com/prod-api",
    prepareHeaders: (headers, { getState }) => {
      headers.set("Content-Type", "application/json");
      headers.set("clienttype", "1");
      headers.set("client", "android");
      headers.set("version", "100");
      const member_token = getState().auth.userToken;

      if (member_token) {
        headers.set("Authorization", member_token);
      }
      return headers;
    },
  }),
  endpoints: (builder) => ({
    getUserDetails: builder.query({
      query: () => ({
        url: "/api/member/info",
        method: "GET",
      }),
    }),
    getUserAuthList: builder.query({
      query: () => ({
        url: "/api/project/authentication/list",
        method: "POST",
      }),
      transformResponse: (response) => {
        console.log("user profile", response);
      },
    }),
    getGlobalDict: builder.query({
      query: () => ({
        url: "/xunapi/dictdata",
        method: "POST",
      }),
      transformResponse: (response) => {
        console.log("dict", response);
      },
    }),
  }),
});

export const {
  useGetUserDetailsQuery,
  useGetUserAuthListQuery,
  useGetGlobalDictQuery,
} = authApi;
