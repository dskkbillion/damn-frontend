import { router } from "expo-router";
import { memo, useCallback, useEffect, useState } from "react";
import { Text } from "react-native";
import MaterialIcons from "react-native-vector-icons/MaterialIcons";
import { useDispatch, useSelector } from "react-redux";
import { Paragraph, Image, XStack, YStack, Theme, H1, Button } from "tamagui";

import { QueryDict } from "@/components/queryDict";
import { useGlobalContext } from "@/components/system/globalContext";
import { AppDispatch, RootState, slices } from "@/src/store";

export default function CertificationPage() {
  const dispatch = useDispatch<AppDispatch>();
  const authList = useSelector((state: RootState) => state.user.authList);
  const [authAuditList, setAuthAuditList] = useState([] as any);
  const [authSupportList, setAuthSupportList] = useState([] as any);
  const { dictData } = useGlobalContext();

  const fetchAuthList = useCallback(async () => {
    try {
      await dispatch(slices.user.actions.fetchUserAuthThunk({}));
    } catch (e) {
      console.log(e);
    }
  }, [dispatch]);

  // get authAuditList (有authenticationAuditVo说明是提交了审核的)
  const getAuthAuditList = useCallback(
    (authList) => {
      const authAuditList = [] as any;
      for (let i = 0; i < authList.length; i++) {
        if (authList[i]?.authenticationAuditVo) {
          authAuditList.push({
            name: authList[i].name,
            authenticationAuditVo: authList[i].authenticationAuditVo,
          });
        }
      }
      return authAuditList;
    },
    [dispatch]
  );

  // 获取开放认证项
  const getAuthSupportList = useCallback((authList) => {
    const authSupportList = [] as any;
    for (let i = 0; i < authList.length; i++) {
      if (authList[i]?.status === "OPEN") {
        authSupportList.push(authList[i]);
      }
    }
    dispatch(slices.user.actions.setAuthOpenList(authSupportList));
    return authSupportList;
  }, []);

  useEffect(() => {
    fetchAuthList();
  }, [fetchAuthList]);

  useEffect(() => {
    if (authList) {
      setAuthAuditList(getAuthAuditList(authList));
      setAuthSupportList(getAuthSupportList(authList));
    }
  }, [authList]);

  console.log("authAuditList", authAuditList);

  return (
    // top：3 authentication
    <Theme name="light">
      <YStack backgroundColor="#fff" borderRadius={20} margin="$3">
        <H1 fontSize={16} marginHorizontal="$3">
          已认证项
        </H1>

        {authAuditList &&
          authAuditList.map((item, index) => {
            return (
              <XStack
                width="100%"
                justifyContent="space-between"
                alignItems="center"
                paddingVertical="$3"
                paddingHorizontal="$3"
                key={index}
              >
                <Paragraph>{item.name}</Paragraph>
                <Button
                  flexDirection="row"
                  alignItems="center"
                  backgroundColor={
                    item?.authenticationAuditVo?.auditStatus === "SUCCESS"
                      ? "$successBox"
                      : item?.authenticationAuditVo?.auditStatus === "FAIL"
                      ? "$failBox"
                      : "#fff"
                  }
                  onPress={() =>
                    router.push(
                      `/(sellerscreens)/profile/authentication/${item?.authenticationAuditVo?.authenticationType}`
                    )
                  }
                  paddingHorizontal="$3"
                  borderRadius={10}
                  unstyled
                >
                  <Paragraph
                    color={
                      item?.authenticationAuditVo?.auditStatus === "SUCCESS"
                        ? "$successText"
                        : item?.authenticationAuditVo?.auditStatus === "FAIL"
                        ? "$failText"
                        : "$darkGray"
                    }
                  >
                    {
                      QueryDict(
                        dictData["authentication_audit_status"],
                        item.authenticationAuditVo?.auditStatus
                      ).label
                    }
                  </Paragraph>
                  <MaterialIcons
                    name="keyboard-arrow-right"
                    size={20}
                    unstyled
                  />
                </Button>
              </XStack>
            );
          })}
      </YStack>

      <Paragraph fontSize={20} color="darkGray" alignSelf="center" margin="$3">
        开放认证...
      </Paragraph>
      <AuthOpenComponent authSupportList={authSupportList} />
    </Theme>
  );
}

const AuthOpenComponent = memo(
  ({ authSupportList }: { authSupportList: any[] }) => {
    // images
    const exampleUniversityAuth = require("@/assets/university_auth.jpg");
    const exampleNameAuth = require("@/assets/name_auth.jpg");
    const noImage = require("@/assets/noimage.jpg");
    const exampleCorporationAuth = require("@/assets/corporation_auth.jpg");
    const { screenWidth, screenHeight, dictData } = useGlobalContext();
    // const CETImage = require("@/assets/CET.jpg");
    // const TOELFImage = require("@/assets/TOELF.jpg");
    // const IELTSImage = require("@/assets/IELTS.jpg");
    // const GMATImage = require("@/assets/GMAT.jpg");
    // const GREImage = require("@/assets/GRE.jpg");

    const sortedList = [
      ...authSupportList.filter((item) => item.type !== "other"),
      ...authSupportList.filter((item) => item.type === "other"),
    ];

    const pickImage = useCallback((type) => {
      switch (type) {
        case "background":
          return exampleUniversityAuth;
        case "real_name":
          return exampleNameAuth;
        case "corporation":
          return exampleCorporationAuth;
        case "other":
          return noImage;
      }
    }, []);

    return (
      <YStack>
        <XStack justifyContent="space-between" flexWrap="wrap">
          {sortedList.map((item, index) => (
            <XStack
              key={index}
              width="32%"
              marginBottom="$3"
              alignItems="center"
              justifyContent="center"
            >
              <Button
                flexDirection="column"
                alignItems="center"
                onPress={() =>
                  router.push(
                    `/(sellerscreens)/profile/authentication/${item.type}`
                  )
                }
                unstyled
              >
                <Image
                  source={pickImage(item.type)}
                  style={{
                    height: screenHeight * 0.09,
                    width: screenWidth * 0.2,
                    borderRadius: 20,
                  }}
                />
                <Text style={{ fontSize: 15, marginTop: 10 }}>
                  {
                    QueryDict(dictData?.["authentication_type"], item.type)
                      .label
                  }
                </Text>
              </Button>
            </XStack>
          ))}
        </XStack>
      </YStack>
    );
  }
);
