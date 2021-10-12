import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:oqueue/api.dart';
import 'package:oqueue/queue_screen.dart';
import './domain.dart';


////////////////////////////
// QueueListScreen

Stream<List<QueueInfo>> queueFetcher(Api api) async* {
  while (true) {
    yield await api.getMyQueues();
    await Future<void>.delayed(const Duration(milliseconds: 200));
  }
}

class QueueListScreen extends StatefulWidget {
  final Api api;

  QueueListScreen({required this.api}) : super();

  @override
  State<StatefulWidget> createState() {
    return QueueListScreenState(infosStream: queueFetcher(api));
  }
}

class QueueListScreenState extends State<QueueListScreen> {
  final Stream<List<QueueInfo>> infosStream;

  QueueListScreenState({required this.infosStream});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Queues')),
        body: StreamBuilder<List<QueueInfo>>(
          stream: infosStream,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(child: CircularProgressIndicator());
            }
            final queueInfos = snapshot.requireData;
            return QueuesList(
              queueInfos: queueInfos,
              me: widget.api.me,
              onDelete: (q) async {
                  final _ = await widget.api.deleteQueue(q.id);
              },
              onCopy: (q) {
                Clipboard.setData(new ClipboardData(text: q.id)).then((_){
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Queue id copied to clipboard"))
                  );
                });
              },
              onLeave: (q) async {
                await widget.api.removeMemberFromQueue(q.id, 'me');
              },
              onSelect: (q) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => QueueScreen(api: widget.api, queueInfo: q)
                  )
                );
              },
            );
          },
        ),
        floatingActionButton: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FloatingActionButton(
              heroTag: 'createMyQueue',
              child: const Icon(Icons.create),
              onPressed: () {
                showCreateQueueModal(context, (name, descr) async {
                  final _queueInfo = await widget.api.createQueue(name, descr);
                });
              },
            ),
            FloatingActionButton(
              heroTag: 'joinToQueue',
              child: const Icon(Icons.add),
              onPressed: () {
                showJoinQueueModal(context, (id) async {
                  final _ = await widget.api.addMemberToQueue(id, 'me');
                });
              },
            ),
          ],
        )
    );
  }
}


// QueueListScreen
////////////////////////////
// QueueList


class QueuesList extends StatelessWidget {
  final List<QueueInfo> queueInfos;
  final UserInfo me;
  final void Function(QueueInfo queueInfo)? onSelect;
  final void Function(QueueInfo queueInfo)? onDelete;
  final void Function(QueueInfo queueInfo)? onLeave;
  final void Function(QueueInfo queueInfo)? onCopy;

  QueuesList({required this.queueInfos, required this.me, this.onSelect, this.onDelete, this.onLeave, this.onCopy, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: queueInfos.length,
      itemBuilder: (context, i) {
        final queueInfo = queueInfos[i];
        return QueueEntryTile(
          queueInfo: queueInfo,
          me: me,
          onDelete: () {
            if(onDelete != null) { onDelete!(queueInfo); }
          },
          onSelect: () {
            if(onSelect != null) { onSelect!(queueInfo); }
          },
          onLeave: () {
            if(onLeave != null) { onLeave!(queueInfo); }
          },
          onCopy: () {
            if(onCopy != null) { onCopy!(queueInfo); }
          }
        );
      },
    );
  }
}


// QueueList
////////////////////////////
// QueueEntryTile


class QueueEntryTile extends StatelessWidget {
  final QueueInfo queueInfo;
  final UserInfo me;
  final void Function()? onSelect;
  final void Function()? onDelete;
  final void Function()? onLeave;
  final void Function()? onCopy;

  QueueEntryTile({required this.queueInfo, required this.me, this.onSelect, this.onDelete, this.onLeave, this.onCopy, Key? key}) : super(key: key);

  List<PopupMenuItem<String>> _buildButtons(BuildContext context) {
    final delete = PopupMenuItem(
      value: 'delete',
      child: ListTile(
        title: Text('Delete'),
        leading: Icon(Icons.clear),
      )
    );
    final copyId = PopupMenuItem(
        value: 'copyId',
        child: ListTile(
          title: Text('Copy Id'),
          leading: Icon(Icons.copy),
        )
    );
    final leave = PopupMenuItem(
        value: 'leave',
        child: ListTile(
          title: Text('Leave'),
          leading: Icon(Icons.arrow_back),
        )
    );
    if(queueInfo.organizerId == me.id) {
      return [copyId, delete];
    } else {
      return [copyId, leave];
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(queueInfo.name),
      subtitle: Text(queueInfo.description),
      trailing: PopupMenuButton<String>(
        itemBuilder: (context) => _buildButtons(context),
        onSelected: (value) {
          switch (value) {
            case 'delete': {
              if(onDelete != null) { onDelete!(); }
              break;
            }
            case 'copyId': {
              if(onCopy != null) { onCopy!(); }
              break;
            }
            case 'leave': {
              if(onLeave != null) { onLeave!(); }
              break;
            }
          }
        },
      ),
      onTap: () {
        if(onSelect != null) { onSelect!(); }
      },
    );
  }
}


// // QueueEntryTile
/////////////////////////////
// CreateQueueModal


class CreateQueueModal extends StatefulWidget {
  final void Function(String name, String description) onSubmit;
  CreateQueueModal(this.onSubmit);

  @override
  State<StatefulWidget> createState() => CreateQueueModalState();
}

class CreateQueueModalState extends State<CreateQueueModal> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController nameController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Container(
        height: 450,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(hintText: 'Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Enter the queue name';
                  }
                  return null;
                },
                controller: nameController,
              ),
              TextFormField(
                decoration: const InputDecoration(hintText: 'Description'),
                controller: descriptionController,
              ),
              ElevatedButton(
                child: const Text('Create'),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    widget.onSubmit(nameController.text, descriptionController.text);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future showCreateQueueModal(BuildContext context, void Function(String name, String descr) onSubmit) async {
  return await showModalBottomSheet<QueueInfo>(
    context: context,
    builder: (context) => CreateQueueModal((name, description) {
      onSubmit(name, description);
      Navigator.pop(context);
    }),
  );
}


// CreateQueueModal
/////////////////////////////
// JoinQueueModal


class JoinQueueModal extends StatefulWidget {
  final void Function(String id) onSubmit;

  JoinQueueModal(this.onSubmit);

  @override
  State<StatefulWidget> createState() => JoinQueueModalState();
}

class JoinQueueModalState extends State<JoinQueueModal> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController idController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Container(
        height: 450,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(hintText: 'id'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Enter the queue id';
                  }
                  return null;
                },
                controller: idController,
              ),
              ElevatedButton(
                child: const Text('Join'),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    widget.onSubmit(idController.text);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future showJoinQueueModal(BuildContext context, void Function(String id) onSubmit) async {
  return await showModalBottomSheet<QueueInfo>(
    context: context,
    builder: (context) => JoinQueueModal((id) {
      onSubmit(id);
      Navigator.pop(context);
    }),
  );
}