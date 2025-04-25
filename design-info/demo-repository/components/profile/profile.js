import { useDispatch, useSelector } from "react-redux";

import { useGetUserDetailsQuery } from "../../services/auth/authService";

const UserProfile = () => {
  const { userInfo } = useSelector((state) => state.auth.userInfo);
  const dispatch = useDispatch();

  const { data, isFetching } = useGetUserDetailsQuery("userDetails", {
    pollingInterval: 900000,
  });

  console.log(data);

  return (
    <div>
      <h1>User Profile</h1>
      <p>{userInfo}</p>
    </div>
  );
};

export default UserProfile;
