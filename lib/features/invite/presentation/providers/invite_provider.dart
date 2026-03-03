import 'package:flutter/material.dart';
import '../../../auth/data/services/user_service.dart';
import '../../../khata/data/models/member_model.dart';
import '../../../khata/data/services/member_service.dart';
import '../../data/models/invite_model.dart';
import '../../data/services/invite_service.dart';

class InviteProvider extends ChangeNotifier {
  final InviteService _inviteService = InviteService();
  final MemberService _memberService = MemberService();
  final UserService _userService = UserService();

  List<InviteModel> _invites = [];
  List<InviteModel> _pendingForUser = [];
  bool _isLoading = false;
  String? _error;

  List<InviteModel> get invites => _invites;
  List<InviteModel> get pendingForUser => _pendingForUser;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadInvites(String accountId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _invites = await _inviteService.getInvitesForAccount(accountId);
    } catch (e) {
      _error = 'Failed to load invites';
      debugPrint('[INVITE] loadInvites error: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadPendingInvitesForUser(String email) async {
    try {
      _pendingForUser =
          await _inviteService.getPendingInvitesForEmail(email);
      notifyListeners();
    } catch (e) {
      debugPrint('[INVITE] loadPendingInvitesForUser error: $e');
    }
  }

  Future<bool> sendInvite({
    required String accountId,
    required String email,
    required String role,
    required String invitedBy,
    required String accountName,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final invite = InviteModel(
        id: '',
        email: email,
        role: role,
        invitedBy: invitedBy,
        accountName: accountName,
        accountId: accountId,
        status: 'pending',
        createdAt: DateTime.now(),
      );

      await _inviteService.sendInvite(accountId, invite);
      await loadInvites(accountId);
      return true;
    } catch (e) {
      _error = 'Failed to send invite';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> acceptInvite(InviteModel invite, {
    required String userId,
    required String userName,
    required String userEmail,
  }) async {
    try {
      // Update invite status
      await _inviteService.updateInviteStatus(
          invite.accountId, invite.id, 'accepted');

      // Add user as member
      final member = MemberModel(
        userId: userId,
        name: userName,
        email: userEmail,
        role: invite.role,
        joinedAt: DateTime.now(),
      );
      await _memberService.addMember(invite.accountId, member);

      // Add account to user
      await _userService.addAccountToUser(userId, invite.accountId);

      _pendingForUser.removeWhere((i) => i.id == invite.id);
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('[INVITE] acceptInvite error: $e');
      return false;
    }
  }

  Future<bool> declineInvite(InviteModel invite) async {
    try {
      await _inviteService.updateInviteStatus(
          invite.accountId, invite.id, 'declined');
      _pendingForUser.removeWhere((i) => i.id == invite.id);
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('[INVITE] declineInvite error: $e');
      return false;
    }
  }
}
