import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:formz/formz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:client/views/photo_gallery.dart';
import 'package:client/misc/const.dart';
import 'package:client/blocs/view/view_bloc.dart';
import 'package:client/blocs/view/view_state.dart';
import 'package:client/blocs/view/view_event.dart';
import 'package:client/blocs/account/account_bloc.dart';
import 'package:client/pages/auth.dart';
import 'package:client/models/report.dart';
import 'package:client/models/comment.dart';


class ReportView extends StatefulWidget {
  const ReportView({Key? key}): super(key: key);

  @override
  State<ReportView> createState() => _ReportViewState();
}

class _ReportViewState extends State<ReportView> {
  Widget _comment(String body, BuildContext context, { String username = "Anonymous", String? photoURL }) {
    return Column(
      children: [
        Row(
          children: [
            CircleAvatar(
              child: photoURL == null ? Text(username[0]) : Image.network(photoURL),
            ),
            const SizedBox(width: MARGIN),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(username, style: Theme.of(context).textTheme.headline6),
                Text(body),
              ],
            ),
          ],
        ),
        const SizedBox(height: MARGIN),
      ],
    );
  }

  Widget _gallery(List<Photo> photos, BuildContext context) {
    return Column(
      children: [
        PhotoGallery.constant(photos),
        const SizedBox(height: MARGIN),
      ],
    );
  }

  Widget _comments(List<Comment> comments, BuildContext context) {
    return Column(
      children: [
        const Divider(
          thickness: 5,
          indent: 20,
          endIndent: 20,
        ),
        const SizedBox(height: MARGIN),

        for (var comment in comments) _comment(comment.text, context, username: comment.subs?.firstName ?? "Anonymous"),
        const SizedBox(height: MARGIN),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.select((AccountBloc bloc) => bloc.state.status);
    return BlocBuilder<ViewBloc, ViewState>(
      buildWhen: (previous, current) => previous.current != current.current,
      builder: (context, state) =>  DraggableScrollableSheet(
        expand: false,
        builder: (_, ScrollController scrollController) {
          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: OFFSET),
            controller: scrollController,
            children: [
              const SizedBox(height: MARGIN),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(state.current.type, style: Theme.of(context).textTheme.headline4),
                  Chip(
                    avatar: CircleAvatar(
                      backgroundColor: Colors.transparent,
                      child: Image.asset(state.current.status.asset),
                    ),
                    label: Text(state.current.status.name),
                  ),
                ],
              ),
              const SizedBox(height: MARGIN),

              Row(
                children: [
                  const Icon(Icons.location_on),
                  const SizedBox(width: MARGIN),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(state.current.address ?? "Address unknown", style: Theme.of(context).textTheme.headline6),
                      Text(state.current.place.toString()),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: MARGIN),

              Row(
                children: [
                  const Icon(Icons.access_time),
                  const SizedBox(width: MARGIN),
                  Text(state.current.date.toString(), style: Theme.of(context).textTheme.headline6),
                ],
              ),
              const SizedBox(height: MARGIN),

              if (state.current.photos.isNotEmpty) _gallery(state.current.photos, context),
              if (state.current.initComment.isNotEmpty) _comment(state.current.initComment, context, username: state.current.subs?.firstName ?? "Anonymous"),

              if (auth) Row(
                children: [
                  _CommentInput(),
                  const SizedBox(width: MARGIN),
                  _SubmitButton(),
                ],
              ) else _CommentUnavailable(),
              const SizedBox(height: MARGIN),

              if (state.current.comments.isNotEmpty) _comments(state.current.comments, context),
              const SizedBox(height: MARGIN),
            ],
          );
        },
      ),
    );
  }
}

class _CommentUnavailable extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: 'Log in',
            style: const TextStyle(color: Colors.blue),
            recognizer: TapGestureRecognizer()
              ..onTap = () => Navigator.of(context, rootNavigator: true).pushNamed(AuthPage.route),
          ),
          TextSpan(
            text: ' to comment this report!',
            style: Theme.of(context).textTheme.bodyText1,
          ),
        ],
      ),
    );
  }
}

class _CommentInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ViewBloc, ViewState>(
      buildWhen: (previous, current) => previous.note != current.note,
      builder: (context, state) => Flexible(
        child: TextField(
          maxLines: 1,
          key: const Key('commentForm_commentInput_textField'),
          onChanged: (comment) => context.read<ViewBloc>().add(ViewNoteChanged(comment)),
          decoration: InputDecoration(
            hintText: "Description: a few words about to add to the report",
            errorText: state.note.invalid ? 'Invalid comment' : null,
          ),
        ),
      ),
    );
  }
}

class _SubmitButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ViewBloc, ViewState>(
      buildWhen: (previous, current) => previous.status != current.status,
      builder: (context, state) => state.status.isSubmissionInProgress ? const CircularProgressIndicator() : ElevatedButton(
        key: const Key('commentForm_submit_button'),
        child: const Text('Submit'),
        onPressed: state.status.isValidated ? () => context.read<ViewBloc>().add(const ViewNoteSubmitted()) : null,
      ),
    );
  }
}
