import { router } from "expo-router";

import { isAxiosSuccess } from "../utils";

import { slices } from "@/src/store";

export const goToChat = async ({ dispatch, tenantId }) => {
  try {
    const res = await dispatch(
      slices.msg.actions.createRoom({ doctorId: tenantId, type: "MEMBER" })
    );

    if (isAxiosSuccess(res.type) && res.payload && "data" in res.payload) {
      router.push({
        pathname: "/(outer)/chatroom",
        params: { chatId: res.payload.data },
      });
    }
  } catch (err) {
    console.error(err);
  }
};
