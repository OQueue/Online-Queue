import 'package:flutter/material.dart';
import './domain.dart';
import './api.dart';


Stream<List<FullMemberInfo>> membersFetcher(Api api, String queueId) async* {
  while (true) {
    final List<MemberInfo> mis = await api.getMembers(queueId);
    List<FullMemberInfo> fmi = [];
    for(var i = 0; i < mis.length; i++) {
      final mi = mis[i];
      final ui = await api.getUser(mi.id);
      fmi.add(FullMemberInfo(
        id: mi.id,
        name: ui.name,
        order: mi.order,
        hasPriority: mi.hasPriority,
        isHeld: mi.isHeld,
        joinedAt: mi.joinedAt
      ));
    }

    yield fmi;
    await Future<void>.delayed(const Duration(milliseconds: 200));
  }
}

class QueueScreen extends StatelessWidget {
  final QueueInfo queueInfo;
  final Api api;

  const QueueScreen({Key? key,
    required this.api,
    required this.queueInfo,
  }) : super(key: key);

  @override
  Widget build(BuildContext ctx) {
    void Function(FullMemberInfo)? onRemove;
    var qi = queueInfo.organizerId;
    var mi = api.me.id;
    print('$qi <=> $mi');
    if(queueInfo.organizerId == api.me.id) {
      print('INIT');
      onRemove = (FullMemberInfo member) async {
        final _ = await api.removeMemberFromQueue(queueInfo.id, member.id);
      };
    }

    return Scaffold(
        appBar: AppBar(title: Text('${queueInfo.name}')),
        body: StreamBuilder<List<FullMemberInfo>>(
          stream: membersFetcher(api, queueInfo.id),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(child: CircularProgressIndicator());
            }
            final memberInfos = snapshot.requireData;
            return MembersList(
              queueInfo: queueInfo,
              memberInfos: memberInfos,
              onRemove: onRemove,
            );
          },
        )
    );
  }
}


class MembersList extends StatelessWidget {
  final QueueInfo queueInfo;
  final List<FullMemberInfo> memberInfos;
  final void Function(FullMemberInfo memberInfo)? onRemove;

  const MembersList({required this.queueInfo, required this.memberInfos, this.onRemove});

  @override
  Widget build(BuildContext context) {

    return ListView.builder(
        itemCount: memberInfos.length,
        itemBuilder: (context, i) {
          final memberInfo = memberInfos[i];
          var onRemove;
          if(this.onRemove != null) {
            onRemove = () { onRemove!(memberInfo); };
          }
          return MemberTile(
            memberInfo: memberInfo,
            queueInfo: queueInfo,
            onRemove: onRemove,
          );
        }
    );
  }
}


class MemberTile extends StatelessWidget {
  final QueueInfo queueInfo;
  final FullMemberInfo memberInfo;
  final void Function()? onRemove;

  const MemberTile({Key? key,
    required this.queueInfo,
    required this.memberInfo,
    this.onRemove,
  }) : super(key: key);

  List<PopupMenuItem<String>> _buildButtons(BuildContext context) {
    final delete = PopupMenuItem(
        value: 'remove',
        child: ListTile(
          title: Text('Remove'),
          leading: Icon(Icons.clear),
        )
    );
    if(onRemove != null) {
      return [delete];
    } else {
      return [];
    }
  }

  PopupMenuButton<String>? _buildPopupMenuButton(BuildContext context) {
    final btns = _buildButtons(context);
    if(btns.isNotEmpty) {
      return PopupMenuButton<String>(
        itemBuilder: (context) => btns,
        onSelected: (value) {
          switch (value) {
            case 'remove': {
              if(onRemove != null) { onRemove!(); }
              break;
            }
          }
        },
      );
    } else {
      return null;
    }
  }

  @override
  Widget build(BuildContext ctx) {


    return ListTile(
      title: Text(memberInfo.name),
      subtitle: Text(formatTime(memberInfo.joinedAt)),
      trailing: _buildPopupMenuButton(ctx),
    );
  }
}

String formatTime(String datetime) {
  final date = datetime.substring(0, 10);
  final time = datetime.substring(11, 19);
  return 'Joined $date $time';
}


