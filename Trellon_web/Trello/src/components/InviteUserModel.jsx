import React, { useState } from 'react';
import { X, Mail, UserPlus, AlertCircle } from 'lucide-react';
import { getUserByEmailAPI } from '../services/UserAPI';
import { inviteUserToWorkspaceAPI } from '../services/WorkspaceAPI';
import { addNotificationAPI } from "../services/NotificationAPI";
import { toast } from 'react-toastify';

export default function InviteUserModal({ workspace, onClose, currentUser, onSuccess }) {
  const [email, setEmail] = useState('');
  const [role, setRole] = useState('Member');
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');

  const handleSubmit = async (e) => {
    e.preventDefault();

    if (!email.trim()) {
      setError('Please enter email');
      return;
    }

    // Validate email
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailRegex.test(email)) {
      setError('Invalid email');
      return;
    }

    setLoading(true);
    setError('');

    try {
      //  Gọi API để tìm user theo email
      const res = await getUserByEmailAPI(email.trim());
      const user = res.data || res; // tùy backend trả JSON hay object
      if (!user?.userUId) {
        setError('No user with this email found');
        setLoading(false);
        return;
      }

      //  Invite user bằng userId
      await inviteUserToWorkspaceAPI(
        workspace.workspaceUId,
        user.userUId,
        currentUser.userUId,
        role
      );

      // Tạo payload notification ngay sau khi mời thành công
      const notificationPayload = {
      recipientId: user.userUId,
      actorId: currentUser.userUId,
      type: 5, // Workspace
      title: "Workspace Invitation",
      message: `${currentUser.userName} invited you to join workspace '${workspace.name}' as ${role}.`,
      link: null,
      workspaceId: workspace.workspaceUId,
    };

    console.log("Workspace payload:", notificationPayload);

    await addNotificationAPI(notificationPayload);

      toast.success(`Invited ${email} to workspace as ${role}`);
      onSuccess?.();
      onClose();

    } catch (err) {
      console.error('Error inviting user:', err);

      if (err.response?.status === 404)
        setError('No user with this email found');
      else if (err.response?.status === 400)
        setError('This user is now a member of this workspace');
      else
        setError('Can\'t invited this user. Please try again later');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div
      className="fixed inset-0 bg-black/50 flex items-center justify-center z-50 p-4 
      dark:bg-black/70"
      onClick={(e) => e.target === e.currentTarget && onClose()}
    >
      <div className="bg-white rounded-xl shadow-2xl max-w-md w-full 
        dark:bg-[#1E1F22] dark:border dark:border-[#2A2D31]">
        
        {/* Header */}
        <div className="flex items-center justify-between p-6 border-b 
          dark:border-[#2A2D31] dark:bg-[#1E1F22]">
          <div>
            <h2 className="text-xl font-semibold text-gray-800 dark:text-[#E8EAED]">
              Invite Member
            </h2>
            <p className="text-sm text-gray-500 mt-1 dark:text-gray-400">
              {workspace.name}
            </p>
          </div>
          <button
            onClick={onClose}
            className="p-2 hover:bg-gray-100 rounded-lg transition
              dark:hover:bg-[#2A2D31]"
          >
            <X size={20} className="text-gray-500 dark:text-gray-300" />
          </button>
        </div>

        {/* Form */}
        <form onSubmit={handleSubmit} className="p-6 space-y-4 dark:bg-[#1E1F22]">
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2 dark:text-gray-300">
              Member's email <span className="text-red-500">*</span>
            </label>
            <div className="relative">
              <Mail 
                className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400 dark:text-gray-300" 
                size={18} 
              />
              <input
                type="email"
                value={email}
                onChange={(e) => {
                  setEmail(e.target.value);
                  setError('');
                }}
                placeholder="user@example.com"
                className="w-full pl-10 pr-4 py-2.5 border border-gray-300 rounded-lg 
                focus:ring-2 focus:ring-blue-500 focus:border-transparent outline-none transition
                dark:bg-[#2A2D31] dark:text-[#E8EAED] dark:border-[#3A3D41] 
                dark:placeholder:text-gray-400"
                disabled={loading}
                autoFocus
              />
            </div>
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2 dark:text-gray-300">
              Role
            </label>
            <select
              value={role}
              onChange={(e) => setRole(e.target.value)}
              className="w-full px-4 py-2.5 border border-gray-300 rounded-lg 
              focus:ring-2 focus:ring-blue-500 outline-none transition
              dark:bg-[#2A2D31] dark:text-[#E8EAED] dark:border-[#3A3D41]"
              disabled={loading}
            >
              <option className="dark:text-white" value="Member">Member</option>
              <option className="dark:text-white" value="Admin">Admin</option>
              <option className="dark:text-white" value="Viewer">Viewer - View only</option>
            </select>
          </div>

          {error && (
            <div className="flex items-start gap-2 p-3 bg-red-50 border border-red-200 rounded-lg
              dark:bg-red-900/30 dark:border-red-700">
              <AlertCircle size={18} className="text-red-600 flex-shrink-0 mt-0.5" />
              <p className="text-sm text-red-700 dark:text-red-400">{error}</p>
            </div>
          )}

          <div className="flex gap-3 pt-2">
            <button
              type="button"
              onClick={onClose}
              className="flex-1 px-4 py-2.5 border border-gray-300 text-gray-700 font-medium rounded-lg 
              hover:bg-gray-50 transition disabled:opacity-50 disabled:cursor-not-allowed
              dark:border-[#3A3D41] dark:text-gray-300 dark:hover:bg-[#2A2D31]"
              disabled={loading}
            >
              Cancel
            </button>

            <button
              type="submit"
              className="flex-1 px-4 py-2.5 bg-blue-600 hover:bg-blue-700 text-white font-medium rounded-lg shadow-sm 
              transition disabled:opacity-50 disabled:cursor-not-allowed"
              disabled={loading}
            >
              {loading ? "Inviting..." : "Invite into workspace"}
            </button>
          </div>
        </form>
      </div>
    </div>
);

}
