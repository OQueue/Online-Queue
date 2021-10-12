class QueueInfo {
  final String id;
  final String name;
  final String description;
  final String organizerId;
  final String createdAt;
  final String existsBefore;

  const QueueInfo(this.id, this.name, this.description, this.organizerId, this.createdAt, this.existsBefore);
}

class MemberInfo {
  final String id;
  final int order;
  final bool hasPriority;
  final bool isHeld;
  final String joinedAt;

  const MemberInfo(this.id, this.order, this.hasPriority, this.isHeld, this.joinedAt);
}

class FullMemberInfo {
  final String id;
  final String name;
  final int order;
  final bool hasPriority;
  final bool isHeld;
  final String joinedAt;

  const FullMemberInfo({
    required this.id,
    required this.name,
    required this.order,
    required this.hasPriority,
    required this.isHeld,
    required this.joinedAt});
}

class UserInfo {
  final String id;
  final String name;

  const UserInfo({required this.id, required this.name});
}
