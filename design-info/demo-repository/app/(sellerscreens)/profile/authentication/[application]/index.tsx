import { Check, Clock } from "@tamagui/lucide-icons";
import { router, useLocalSearchParams } from "expo-router";
import { memo, useCallback, useEffect, useState } from "react";
import {
  GestureResponderEvent,
  Keyboard,
  Modal,
  TouchableWithoutFeedback,
} from "react-native";
import FastImage from "react-native-fast-image";
import MaterialIcons from "react-native-vector-icons/MaterialIcons";
import { useDispatch, useSelector } from "react-redux";
import {
  Button,
  Input,
  Paragraph,
  PortalProvider,
  View,
  XStack,
  YStack,
} from "tamagui";

import { QueryDict } from "@/components/queryDict";
import {
  BottomImagePickerSheet,
  PickUpButton,
} from "@/components/styled/bottomsheet_picker";
import { AlertDialogComponent } from "@/components/styled/dialog_comp";
import {
  ImagePreviewComp,
  ImagePreviewEditComp,
} from "@/components/styled/preview_image";
import { useGlobalContext } from "@/components/system/globalContext";
import { isAxiosSuccess } from "@/components/utils";
import { getFilePath, goToUpload } from "@/components/utils/filesystem";
import { AppDispatch, fileSlice, RootState, slices } from "@/src/store";
import React from "react";

/**
 * @description: 认证编辑页面
 * @localSearchParams: auth 认证类型(real_name, background, corporation, other)
 */
export default function AuthApplicationPage() {
  const params = useLocalSearchParams();
  const auth = params.application as string; // application type
  const dispatch = useDispatch<AppDispatch>();
  const [popup, setPopup] = useState(false);
  const [previewPopup, setPreviewPopup] = useState(false);
  const [previewIndex, setPreviewIndex] = useState(0);
  const authImages = useSelector((state: RootState) => state.file.authImages);
  const uploadIndex = useSelector((state: RootState) => state.file.uploadIndex);
  const authList = useSelector((state: RootState) => state.user.authList);

  const handleConfirm = useCallback(
    async ({ type, data }) => {
      let params;
      let images;
      if (type === "real_name") {
        images = [
          authImages["real_name"]["front"][0]?.imgUrl,
          authImages["real_name"]["back"][0]?.imgUrl,
        ];
      } else {
        images = authImages[type].map((image) => image.imgUrl);
      }

      switch (type) {
        // 实名认证
        case "real_name":
          if (images.length < 2) {
            alert("请上传身份证正反面");
            return;
          }
          params = {
            authenticationId: 1,
            images,
          };
          break;
        case "background":
          // 学校认证
          if (images.length === 0) {
            alert("请上传学位证书");
            return;
          } else if (!data?.schoolName) {
            alert("请输入学校名称");
            return;
          }
          params = {
            authenticationId: 2,
            feature: {
              name: data?.schoolName,
            },
            remarks: data?.nickname,
            images,
          };
          break;
        case "corporation":
          // 公司认证
          if (!data?.companyName) {
            alert("请输入公司名称");
            return;
          }
          if (images.length === 0) {
            alert("请上传营业执照");
            return;
          } else {
            params = {
              authenticationId: 3,
              feature: {
                name: data?.companyName,
              },
              images,
            };
          }
          break;
        case "other":
          // 其他认证
          if (!data?.name) {
            alert("请选择认证资质");
            return;
          } else if (images.length === 0) {
            alert("请上传资质证书");
            return;
          } else {
            params = {
              authenticationId: 4,
              name: data?.name,
              images,
            };
          }
          break;
      }

      try {
        // console.log("params", params);
        const res = await dispatch(slices?.user?.actions?.addAuthAudit(params));
        if (isAxiosSuccess(res.type)) {
          alert("提交成功");
          dispatch(slices?.user?.actions?.resetAuthList()); // 重置认证列表（使前一页刷新）
          router.back();
        } else {
          alert(res.payload?.msg);
        }
      } catch (e) {
        console.log("fail to addAuthAudit ", e);
      }
    },
    [authImages]
  );

  const deleteImage = (index: number) => {
    dispatch(fileSlice.file.actions.deleteImage(index));
  };

  const handleImageClick = (index: number) => {
    setPreviewPopup(true);
    setPreviewIndex(index);
  };

  const handleImageClick_realName = ({
    index,
    uploadIndex,
  }: {
    index: number;
    uploadIndex: number;
  }) => {
    setPreviewPopup(true);
    setPreviewIndex(index);
    dispatch(fileSlice.file.actions.setUploadIndex(uploadIndex));
  };

  const renderAuthContent = (auth: string) => {
    switch (auth) {
      case "background":
        return (
          <UniversityAuthContent
            setPopup={setPopup}
            handleConfirm={handleConfirm}
            handleImageClick={handleImageClick}
          />
        );
      case "real_name":
        return (
          <RealNameAuthContent
            setPopup={setPopup}
            handleConfirm={handleConfirm}
            handleImageClick={handleImageClick_realName}
          />
        );
      case "corporation":
        return (
          <CompanyAuthContent
            setPopup={setPopup}
            handleConfirm={handleConfirm}
            handleImageClick={handleImageClick}
          />
        );
      default: //
        return (
          <MoreAuthContenr
            setPopup={setPopup}
            handleConfirm={handleConfirm}
            handleImageClick={handleImageClick}
          />
        );
    }
  };

  return (
    <YStack flex={1}>
      {Object.keys(
        authList.find((item) => item.type === auth)?.authenticationAuditVo || {}
      ).length > 0 ? (
        <AuthStatusComp type={auth} />
      ) : (
        renderAuthContent(auth)
      )}
      {/* 底部图片弹窗 */}
      <BottomImagePickerSheet
        isOpen={popup}
        onClose={() => {
          setPopup(false);
        }}
        goToUpload={(action) => {
          Keyboard.dismiss();
          goToUpload({
            action,
            type: `auth_${auth}`,
            setPopup,
            selectionLimit: auth === "other" ? 9 : 1,
            dispatch,
          });
        }}
      />
      {previewPopup && (
        <ImagePreviewEditComp
          images={
            auth === "real_name"
              ? authImages["real_name"][uploadIndex === 0 ? "front" : "back"]
              : authImages[auth]
          }
          previewIndex={previewIndex}
          modal={previewPopup}
          setModal={setPreviewPopup}
          deleteImage={deleteImage}
          type={`auth_${auth}`}
        />
      )}
    </YStack>
  );
}

interface AuthParams {
  setPopup: (popup: boolean) => void;
  handleConfirm: (params: any) => void;
  handleImageClick: (index: number) => void;
}

// 实名认证
const RealNameAuthContent = memo(
  ({
    setPopup,
    handleConfirm,
    handleImageClick,
  }: {
    setPopup: (popup: boolean) => void;
    handleConfirm: (params: any) => void;
    handleImageClick: any;
  }) => {
    const authImages = useSelector((state: RootState) => state.file.authImages);
    const frontImage = authImages["real_name"]["front"];
    const backImage = authImages["real_name"]["back"];

    return (
      <YStack
        width="100%"
        paddingHorizontal="$3"
        paddingVertical="$4"
        backgroundColor="white"
      >
        {/* 身份证正面提示 */}
        <YStack marginBottom="$4">
          <Paragraph marginBottom="$2" style={{ color: "grey" }}>
            请上传您的身份证正面（人像面）：
          </Paragraph>

          {frontImage.length === 0 ? (
            <PickUpButton
              width="100%"
              height={200}
              setPopup={setPopup}
              type="auth_real_name"
              uploadIndex={0}
            />
          ) : (
            <TouchableWithoutFeedback
              onPress={() => handleImageClick({ index: 0, uploadIndex: 0 })}
            >
              <View>
                <FastImage
                  source={{
                    uri: frontImage[0]?.imgUrl,
                    priority: FastImage.priority.high,
                  }}
                  style={{ width: "100%", height: 200 }}
                />
              </View>
            </TouchableWithoutFeedback>
          )}
        </YStack>

        {/* 身份证反面提示 */}
        <YStack marginBottom="$4">
          <Paragraph marginBottom="$2" style={{ color: "grey" }}>
            请上传您的身份证反面（国徽面）：
          </Paragraph>

          {backImage.length === 0 ? (
            <PickUpButton
              width="100%"
              height={200}
              setPopup={setPopup}
              type="auth_real_name"
              uploadIndex={1}
            />
          ) : (
            <TouchableWithoutFeedback
              onPress={() => handleImageClick({ index: 0, uploadIndex: 1 })}
            >
              <View>
                <FastImage
                  source={{
                    uri: backImage[0]?.imgUrl,
                    priority: FastImage.priority.high,
                  }}
                  style={{ width: "100%", height: 200 }}
                />
              </View>
            </TouchableWithoutFeedback>
          )}
        </YStack>

        {/* 上传按钮 */}
        <AlertDialogComponent
          title="申请认证"
          description="是否确认提交认证申请？"
          handleConfirm={() => {
            handleConfirm({
              type: "real_name",
              data: null,
            });
          }}
        >
          <Button
            backgroundColor="#caa472"
            borderRadius="$5"
            paddingHorizontal="$5"
            paddingVertical="$2"
            alignSelf="center"
            height={40}
            style={{ color: "white" }}
          >
            确认提交
          </Button>
        </AlertDialogComponent>
      </YStack>
    );
  }
);

/**
 * @description: 学校认证组件
 */
const UniversityAuthContent = memo(
  ({ setPopup, handleConfirm, handleImageClick }: AuthParams) => {
    const [schoolName, setSchoolName] = useState("");
    const [nickname, setNickname] = useState("");
    const authImages = useSelector((state: RootState) => state.file.authImages);
    const images =
      authImages["background"].length > 0
        ? authImages["background"].map((image) => image.imgUrl)
        : [];
    return (
      <YStack flex={1} backgroundColor="white" padding="$4" space>
        <Paragraph color="grey">请输入您的学校：</Paragraph>
        <Input
          placeholder="请输入"
          borderColor="lightgray"
          value={schoolName}
          onChangeText={setSchoolName}
          height="$3"
        />

        <XStack justifyContent="space-between" alignItems="center">
          <Paragraph color="grey">可编辑个性化别称（选填）：</Paragraph>
          <MaterialIcons name="help-outline" size={20} color="#D07F29" />
        </XStack>

        <Input
          placeholder="请输入"
          borderColor="lightgray"
          marginBottom="$2"
          value={nickname}
          onChangeText={setNickname}
          height="$3"
        />

        <Paragraph color="grey">请上传学位证书：</Paragraph>

        {images.length === 0 ? (
          <PickUpButton
            width="100%"
            height={150}
            setPopup={setPopup}
            type="auth_background"
          />
        ) : (
          <TouchableWithoutFeedback onPress={() => handleImageClick(0)}>
            <View>
              <FastImage
                source={{ uri: images[0], priority: FastImage.priority.high }}
                style={{ width: "100%", height: 150 }}
              />
            </View>
          </TouchableWithoutFeedback>
        )}

        <Paragraph marginTop="$2" marginBottom="$2" color="#D07F29">
          注意事项
        </Paragraph>
        <Paragraph color="grey">
          1.拍摄与所填学校全称一致的学位证书上传
        </Paragraph>
        <Paragraph marginBottom="$4" color="grey">
          2.需先完成实名认证
        </Paragraph>

        <AlertDialogComponent
          title="申请认证"
          description="是否确认提交认证申请？"
          handleConfirm={() => {
            handleConfirm({
              type: "background",
              data: { schoolName, nickname },
            });
          }}
        >
          <Button
            backgroundColor="#caa472"
            borderRadius="$5"
            paddingHorizontal="$5"
            paddingVertical="$2"
            alignSelf="center"
            height={40}
            style={{ color: "white" }}
          >
            确认提交
          </Button>
        </AlertDialogComponent>
      </YStack>
    );
  }
);

const CompanyAuthContent = memo(
  ({ setPopup, handleConfirm, handleImageClick }: AuthParams) => {
    const [companyName, setCompanyName] = useState("");
    const authImages = useSelector((state: RootState) => state.file.authImages);
    const images =
      authImages["corporation"].length > 0
        ? authImages["corporation"].map((image) => image.imgUrl)
        : [];

    return (
      <YStack flex={1} backgroundColor="white" padding="$4" space>
        <XStack
          backgroundColor="#F8E1C2"
          padding="$2"
          borderRadius="$2"
          alignItems="center"
        >
          <MaterialIcons name="notifications" size={24} color="#D07F29" />
          <Paragraph margin="$4" color="#D07F29">
            请确保提交的认证材料真实有效，否则您可能需要承担相应违法违规后果。
          </Paragraph>
        </XStack>
        <Paragraph color="grey">您的公司全称：</Paragraph>
        <Input
          placeholder="请输入"
          borderColor="lightgray"
          value={companyName}
          onChangeText={setCompanyName}
          height="$3"
        />

        <Paragraph color="grey">请上传营业执照：</Paragraph>

        {images.length === 0 ? (
          <PickUpButton
            width="100%"
            height={150}
            setPopup={setPopup}
            type="auth_corporation"
          />
        ) : (
          <TouchableWithoutFeedback onPress={() => handleImageClick(0)}>
            <View>
              <FastImage
                source={{ uri: images[0], priority: FastImage.priority.high }}
                style={{ width: "100%", height: 150 }}
              />
            </View>
          </TouchableWithoutFeedback>
        )}

        <Paragraph
          marginTop="$2"
          marginBottom="$1"
          color="#D07F29"
          fontWeight="bold"
        >
          注意事项
        </Paragraph>
        <Paragraph color="grey">
          1.拍摄与所填公司全称一致的营业执照上传
        </Paragraph>
        <Paragraph color="grey">2.最新下发的营业执照</Paragraph>
        <Paragraph color="grey" marginBottom="$2">
          3.需先完成实名认证
        </Paragraph>

        <AlertDialogComponent
          title="申请认证"
          description="是否确认提交认证申请？"
          handleConfirm={() => {
            handleConfirm({
              type: "corporation",
              data: { companyName },
            });
          }}
        >
          <Button
            backgroundColor="#caa472"
            borderRadius="$5"
            paddingHorizontal="$5"
            paddingVertical="$2"
            alignSelf="center"
            height={40}
            style={{ color: "white" }}
          >
            确认提交
          </Button>
        </AlertDialogComponent>
      </YStack>
    );
  }
);

const MoreAuthContenr = memo(
  ({ setPopup, handleConfirm, handleImageClick }: AuthParams) => {
    const [isModalVisible, setModalVisible] = useState(false);
    const authOpenList = useSelector(
      (state: RootState) => state.user.authOpenList
    );
    const [optionList, setOptionList] = useState<any[]>([]);
    const [selected, setSelected] = useState<string>("");
    const openSelectModal = (event: GestureResponderEvent) => {
      setModalVisible(true);
    };
    const authImages = useSelector((state: RootState) => state.file.authImages);
    const images =
      authImages["other"].length > 0
        ? authImages["other"].map((image) => image.imgUrl)
        : [];
    const { screenWidth } = useGlobalContext();

    const closeSelectModal = () => {
      setModalVisible(false);
    };

    const handleChosen = useCallback((value) => {
      setModalVisible(false);
      setSelected(value);
    }, []);

    useEffect(() => {
      // fetch authSupportList
      if (authOpenList) {
        const optionList = authOpenList.filter(
          (item) => item?.type === "other"
        );
        setOptionList(optionList);
      }
    }, [authOpenList]);

    return (
      <>
        <YStack
          paddingHorizontal="$4"
          paddingVertical="$4"
          backgroundColor="white"
          flex={1}
          space="$3"
        >
          <YStack height={100}>
            <Paragraph color="grey" marginBottom="$2">
              请选择您想认证的资质：
            </Paragraph>
            {/* 弹窗触发按钮 */}
            {selected === "" ? (
              <Button
                backgroundColor="#caa472"
                color="white"
                alignSelf="center"
                borderRadius={10}
                paddingHorizontal="$6"
                paddingVertical="$2"
                height={40}
                onPress={openSelectModal}
              >
                待选择
              </Button>
            ) : (
              <XStack justifyContent="space-between" alignItems="center">
                <Paragraph fontSize={18}>{selected}</Paragraph>
                <Button
                  backgroundColor="#caa472"
                  color="white"
                  alignSelf="center"
                  borderRadius={10}
                  paddingHorizontal="$6"
                  onPress={openSelectModal}
                  height={40}
                >
                  重新选择
                </Button>
              </XStack>
            )}
          </YStack>

          {/* 弹窗 Modal */}
          {isModalVisible && (
            <PortalProvider>
              <Modal
                visible={isModalVisible}
                onDismiss={closeSelectModal}
                transparent
                animationType="slide"
              >
                <YStack
                  justifyContent="center"
                  alignItems="center"
                  flex={1}
                  backgroundColor="rgba(0, 0, 0, 0.5)"
                >
                  <YStack
                    backgroundColor="white"
                    padding="$4"
                    borderRadius="$2"
                    width="80%"
                    justifyContent="center"
                    alignItems="center"
                  >
                    <Paragraph fontWeight="bold" fontSize={18}>
                      选择您想认证的资质
                    </Paragraph>

                    {optionList.map((item, index) => (
                      <Button
                        key={index}
                        marginVertical="$2"
                        height={40}
                        onPress={() => {
                          /* 选中 GRE 逻辑 */
                          handleChosen(item?.name);
                        }}
                      >
                        {item?.name}
                      </Button>
                    ))}

                    <Button
                      marginVertical="$2"
                      color="gray"
                      height={40}
                      onPress={closeSelectModal}
                    >
                      取消
                    </Button>
                  </YStack>
                </YStack>
              </Modal>
            </PortalProvider>
          )}

          <Paragraph marginBottom="$2" color="grey">
            请上传您的资质：(最多上传9张)
          </Paragraph>
          {images.length === 0 ? (
            <PickUpButton
              width="100%"
              height={150}
              setPopup={setPopup}
              type="auth_other"
            />
          ) : (
            <XStack
              flexWrap="wrap"
              gap={10}
              justifyContent="flex-start"
              width="100%"
            >
              {images.map((image, index) => (
                <Button
                  key={index}
                  width={(screenWidth - 20 - 36) / 3}
                  onPress={() => handleImageClick(index)}
                  unstyled
                >
                  {/* <Paragraph>{image}</Paragraph> */}
                  <FastImage
                    source={{
                      uri: getFilePath(image),
                      priority: FastImage.priority.high,
                    }}
                    resizeMode={FastImage.resizeMode.stretch}
                    style={{
                      width: "100%",
                      aspectRatio: 1,
                    }}
                  />
                </Button>
              ))}
              {images.length < 9 && (
                <PickUpButton
                  width={(screenWidth - 20 - 36) / 3}
                  height={(screenWidth - 20 - 36) / 3}
                  setPopup={setPopup}
                  type="auth_other"
                />
              )}
            </XStack>
          )}
        </YStack>
        <XStack width="100%" justifyContent="center" height={100}>
          <AlertDialogComponent
            title="申请认证"
            description="是否确认提交认证申请？"
            handleConfirm={() => {
              handleConfirm({
                type: "other",
                data: {
                  name: selected,
                },
              });
            }}
          >
            <Button
              backgroundColor="#caa472"
              borderRadius="$5"
              paddingHorizontal="$5"
              paddingVertical="$2"
              alignSelf="center"
              height={40}
              style={{ color: "white" }}
            >
              确认提交
            </Button>
          </AlertDialogComponent>
        </XStack>
      </>
    );
  }
);

const AuthStatusComp = memo(({ type }: { type: string }) => {
  const authList = useSelector((state: RootState) => state.user.authList);
  const auth = useLocalSearchParams();
  const { dictData, screenWidth } = useGlobalContext();
  const authDetail = authList.find((item) => item.type === auth.application);
  const auditVo = authDetail?.authenticationAuditVo;
  const [previewPopup, setPreviewPopup] = useState(false);
  const [previewIndex, setPreviewIndex] = useState(0);

  // 添加调试信息
  console.log("AuthStatusComp - type:", type);
  console.log("AuthStatusComp - auth.application:", auth.application);
  console.log("AuthStatusComp - authList:", JSON.stringify(authList, null, 2));
  console.log("AuthStatusComp - authDetail:", JSON.stringify(authDetail, null, 2));
  console.log("AuthStatusComp - auditVo:", JSON.stringify(auditVo, null, 2));

  const handlePreview = (index: number) => {
    setPreviewIndex(index);
    setPreviewPopup(true);
  };

  const renderStatusIcon = (status: string) => {
    switch (status) {
      case "SUCCESS":
        return <Check size={24} color="#4CAF50" />;
      case "WAIT":
        return <Clock size={24} color="#FFC107" />;
      default:
        return null;
    }
  };

  const renderAuthInfo = () => {
    switch (type) {
      case "real_name":
        return (
          <YStack space="$2">
            <XStack alignItems="center" space="$2">
              <Paragraph color="$gray11">认证状态：</Paragraph>
              <XStack alignItems="center" space="$2">
                {renderStatusIcon(auditVo?.auditStatus)}
                <Paragraph color="$brown">
                  {
                    QueryDict(
                      dictData["authentication_audit_status"],
                      auditVo?.auditStatus
                    ).label
                  }
                </Paragraph>
              </XStack>
            </XStack>
            {auditVo?.auditRemark && (
              <XStack space="$2">
                <Paragraph color="$gray11">审核备注：</Paragraph>
                <Paragraph>{auditVo.auditRemark}</Paragraph>
              </XStack>
            )}
            <YStack space="$2">
              <Paragraph color="$gray11">证件照片：</Paragraph>
              <XStack flexWrap="wrap" gap={10}>
                {auditVo?.images && auditVo.images.length > 0 ? (
                  auditVo.images.map((img, index) => (
                    <Button
                      key={index}
                      onPress={() => {
                        handlePreview(index);
                      }}
                      unstyled
                    >
                      <FastImage
                        source={{ uri: img, priority: FastImage.priority.high }}
                        style={{
                          width: 150,
                          height: 100,
                          borderRadius: 8,
                        }}
                        resizeMode={FastImage.resizeMode.contain}
                        defaultSource={require("@/assets/noimage.jpg")}
                      />
                    </Button>
                  ))
                ) : (
                  <View
                    style={{
                      width: 150,
                      height: 100,
                      borderRadius: 8,
                      backgroundColor: "#f0f0f0",
                      justifyContent: "center",
                      alignItems: "center",
                      overflow: "hidden",
                    }}
                  >
                    <FastImage
                      source={require("@/assets/name_auth.jpg")}
                      style={{
                        width: "100%",
                        height: "100%",
                        opacity: 0.7,
                      }}
                      resizeMode={FastImage.resizeMode.contain}
                    />
                    <Paragraph
                      color="$gray11"
                      style={{
                        position: 'absolute',
                        textAlign: 'center',
                        backgroundColor: 'rgba(255,255,255,0.7)',
                        padding: 5,
                        borderRadius: 5,
                        fontSize: 12,
                      }}
                    >
                      暂无证件照片
                    </Paragraph>
                  </View>
                )}
              </XStack>
            </YStack>
          </YStack>
        );

      case "background":
        return (
          <YStack space="$2">
            <XStack alignItems="center" space="$2">
              <Paragraph color="$gray11">认证状态：</Paragraph>
              <XStack alignItems="center" space="$2">
                {renderStatusIcon(auditVo?.auditStatus)}
                <Paragraph color="$brown">
                  {
                    QueryDict(
                      dictData["authentication_audit_status"],
                      auditVo?.auditStatus
                    ).label
                  }
                </Paragraph>
              </XStack>
            </XStack>
            <XStack space="$2">
              <Paragraph color="$gray11">学校名称：</Paragraph>
              <Paragraph>{auditVo?.feature?.name || "未设置"}</Paragraph>
            </XStack>
            {auditVo?.remarks && (
              <XStack space="$2">
                <Paragraph color="$gray11">个性化别称：</Paragraph>
                <Paragraph>{auditVo.remarks}</Paragraph>
              </XStack>
            )}
            <YStack space="$2">
              <Paragraph color="$gray11">证书照片：</Paragraph>
              {auditVo?.images && auditVo.images.length > 0 && auditVo.images[0] ? (
                <TouchableWithoutFeedback
                  onPress={() => {
                    handlePreview(0);
                  }}
                >
                  <View style={{ width: "100%", height: 200, borderRadius: 8 }}>
                    <FastImage
                      source={{ uri: auditVo.images[0], priority: FastImage.priority.high }}
                      style={{
                        width: "100%",
                        height: 200,
                        borderRadius: 8,
                      }}
                      resizeMode={FastImage.resizeMode.contain}
                      defaultSource={require("@/assets/noimage.jpg")}
                    />
                  </View>
                </TouchableWithoutFeedback>
              ) : (
                <View
                  style={{
                    width: "100%",
                    height: 200,
                    borderRadius: 8,
                    backgroundColor: "#f0f0f0",
                    justifyContent: "center",
                    alignItems: "center",
                    overflow: "hidden",
                  }}
                >
                  <FastImage
                    source={require("@/assets/university_auth.jpg")}
                    style={{
                      width: "100%",
                      height: 200,
                      borderRadius: 8,
                      opacity: 0.7,
                    }}
                    resizeMode={FastImage.resizeMode.contain}
                  />
                  <Paragraph
                    color="$gray11"
                    style={{
                      position: 'absolute',
                      textAlign: 'center',
                      backgroundColor: 'rgba(255,255,255,0.7)',
                      padding: 10,
                      borderRadius: 5,
                    }}
                  >
                    暂无证书照片
                  </Paragraph>
                </View>
              )}
            </YStack>
          </YStack>
        );

      case "corporation":
        return (
          <YStack space="$2">
            <XStack alignItems="center" space="$2">
              <Paragraph color="$gray11">认证状态：</Paragraph>
              <XStack alignItems="center" space="$2">
                {renderStatusIcon(auditVo?.auditStatus)}
                <Paragraph color="$brown">
                  {
                    QueryDict(
                      dictData["authentication_audit_status"],
                      auditVo?.auditStatus
                    ).label
                  }
                </Paragraph>
              </XStack>
            </XStack>
            <XStack space="$2">
              <Paragraph color="$gray11">公司名称：</Paragraph>
              <Paragraph>{auditVo?.feature?.name || "未设置"}</Paragraph>
            </XStack>
            <YStack space="$2">
              <Paragraph color="$gray11">营业执照：</Paragraph>
              {auditVo?.images && auditVo.images.length > 0 && auditVo.images[0] ? (
                <TouchableWithoutFeedback
                  onPress={() => {
                    handlePreview(0);
                  }}
                >
                  <View style={{ width: "100%", height: 200, borderRadius: 8 }}>
                    <FastImage
                      source={{ uri: auditVo.images[0], priority: FastImage.priority.high }}
                      style={{
                        width: "100%",
                        height: 200,
                        borderRadius: 8,
                      }}
                      resizeMode={FastImage.resizeMode.contain}
                      defaultSource={require("@/assets/noimage.jpg")}
                    />
                  </View>
                </TouchableWithoutFeedback>
              ) : (
                <View
                  style={{
                    width: "100%",
                    height: 200,
                    borderRadius: 8,
                    backgroundColor: "#f0f0f0",
                    justifyContent: "center",
                    alignItems: "center",
                  }}
                >
                  <FastImage
                    source={require("@/assets/corporation_auth.jpg")}
                    style={{
                      width: "100%",
                      height: 200,
                      borderRadius: 8,
                      opacity: 0.7,
                    }}
                    resizeMode={FastImage.resizeMode.contain}
                  />
                  <Paragraph
                    color="$gray11"
                    style={{
                      position: 'absolute',
                      textAlign: 'center',
                      backgroundColor: 'rgba(255,255,255,0.7)',
                      padding: 10,
                      borderRadius: 5,
                    }}
                  >
                    暂无营业执照图片
                  </Paragraph>
                </View>
              )}
            </YStack>
          </YStack>
        );

      case "other":
        return (
          <YStack space="$2">
            <XStack alignItems="center" space="$2">
              <Paragraph color="$gray11">认证状态：</Paragraph>
              <XStack alignItems="center" space="$2">
                {renderStatusIcon(auditVo?.auditStatus)}
                <Paragraph color="$brown">
                  {
                    QueryDict(
                      dictData["authentication_audit_status"],
                      auditVo?.auditStatus
                    ).label
                  }
                </Paragraph>
              </XStack>
            </XStack>
            <XStack space="$2">
              <Paragraph color="$gray11">认证类型：</Paragraph>
              <Paragraph>{auditVo?.name || "未设置"}</Paragraph>
            </XStack>
            <YStack space="$2">
              <Paragraph color="$gray11">资质证书：</Paragraph>
              <XStack flexWrap="wrap" gap={10}>
                {auditVo?.images && auditVo.images.length > 0 ? (
                  auditVo.images.map((img, index) => (
                    <TouchableWithoutFeedback
                      key={index}
                      onPress={() => {
                        handlePreview(index);
                      }}
                    >
                      <View>
                        <FastImage
                          source={{ uri: img, priority: FastImage.priority.high }}
                          style={{
                            width: (screenWidth - 40 - 20) / 3,
                            aspectRatio: 1,
                            borderRadius: 8,
                          }}
                          resizeMode={FastImage.resizeMode.contain}
                          defaultSource={require("@/assets/noimage.jpg")}
                        />
                      </View>
                    </TouchableWithoutFeedback>
                  ))
                ) : (
                  <View
                    style={{
                      width: (screenWidth - 40 - 20) / 3,
                      aspectRatio: 1,
                      borderRadius: 8,
                      backgroundColor: "#f0f0f0",
                      justifyContent: "center",
                      alignItems: "center",
                      overflow: "hidden",
                    }}
                  >
                    <FastImage
                      source={require("@/assets/GRE.jpg")}
                      style={{
                        width: "100%",
                        height: "100%",
                        opacity: 0.7,
                      }}
                      resizeMode={FastImage.resizeMode.contain}
                    />
                    <Paragraph
                      color="$gray11"
                      style={{
                        position: 'absolute',
                        textAlign: 'center',
                        backgroundColor: 'rgba(255,255,255,0.7)',
                        padding: 5,
                        borderRadius: 5,
                        fontSize: 12,
                      }}
                    >
                      暂无资质证书
                    </Paragraph>
                  </View>
                )}
              </XStack>
            </YStack>
          </YStack>
        );

      default:
        return null;
    }
  };

  useEffect(() => {}, []);

  return (
    <>
      <YStack backgroundColor="white" padding="$4" space="$4" flex={1}>
        {renderAuthInfo()}
      </YStack>

      {/* 添加图片预览组件 */}
      {previewPopup && auditVo?.images && auditVo.images.length > 0 && (
        <ImagePreviewComp
          images={auditVo.images || []}
          previewIndex={previewIndex}
          modal={previewPopup}
          setModal={setPreviewPopup}
        />
      )}
    </>
  );
});
