import 'package:flutter/material.dart';
import 'package:harpy/api/twitter/data/tweet.dart';
import 'package:harpy/components/widgets/media/tweet_media.dart';
import 'package:harpy/components/widgets/shared/animations.dart';
import 'package:harpy/components/widgets/shared/loading_tile.dart';
import 'package:harpy/components/widgets/shared/scaffolds.dart';
import 'package:harpy/components/widgets/tweet/tweet_list.dart';
import 'package:harpy/components/widgets/tweet/tweet_tile.dart';
import 'package:harpy/components/widgets/tweet/tweet_tile_content.dart';
import 'package:harpy/components/widgets/tweet/tweet_tile_quote.dart';
import 'package:harpy/models/tweet_model.dart';
import 'package:harpy/models/tweet_replies_model.dart';
import 'package:provider/provider.dart';

/// Shows a [Tweet] and all of its replies in a list.
class TweetRepliesScreen extends StatelessWidget {
  const TweetRepliesScreen({
    @required this.tweet,
  });

  static const String route = "replies";

  final Tweet tweet;

  Widget _buildLeading(TweetRepliesModel model) {
    return Column(
      children: <Widget>[
        _TweetReplyParents(model.parentTweets),
        if (model.parentTweets.isNotEmpty)
          TweetReplyParent(authors: model.tweet.user.name),
        _BigTweetTile(tweet: tweet),
      ],
    );
  }

  Widget _buildPlaceholder(BuildContext context, TweetRepliesModel model) {
    final textTheme = Theme.of(context).textTheme;

    if (model.loading) {
      return const LoadingTweetTile(
        padding: EdgeInsets.fromLTRB(56, 8, 8, 8),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: <Widget>[
            const Text("No replies found"),
            Text(
              "Only replies of the last 7 days can be retrieved.",
              style: textTheme.body2,
            ),
          ],
        ),
      );
    }
  }

  Widget _buildBody(BuildContext context) {
    return Consumer<TweetRepliesModel>(
      builder: (context, model, _) {
        return SlideFadeInAnimation(
          offset: const Offset(0, 100),
          child: TweetList(
            leading: _buildLeading(model),
            placeHolder: _buildPlaceholder(context, model),
            tweets: model.replies,
            onLoadMore: model.loadMore,
            enableLoadMore: !model.lastPage,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<TweetRepliesModel>(
      create: (_) => TweetRepliesModel(
        tweet: tweet,
      ),
      child: HarpyScaffold(
        title: "Replies",
        body: _buildBody(context),
      ),
    );
  }
}

/// A [Tweet] displayed in a tile for the [TweetRepliesScreen].
///
/// Very similar to [TweetTile] at the moment but can be used for a different
/// look of the selected tweet.
class _BigTweetTile extends StatefulWidget {
  const _BigTweetTile({
    @required this.tweet,
  });

  final Tweet tweet;

  @override
  _BigTweetTileState createState() => _BigTweetTileState();
}

class _BigTweetTileState extends State<_BigTweetTile> {
  Widget _buildContent(BuildContext context) {
    final model = TweetModel.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        TweetRetweetedRow(model),
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TweetTopRow(model),
              TweetText(model),
              TweetQuote(model),
              TweetTranslation(model),
              if (model.hasMedia) CollapsibleMedia(),
              TweetActionsRow(model),
            ],
          ),
        ),
        const Divider(height: 0),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return TweetTile.custom(
      tweet: widget.tweet,
      content: Builder(
        builder: _buildContent,
      ),
    );
  }
}

/// Displays the parent [Tweet]s.
///
/// When the parents are loaded, they will animate into the view using an
/// [AnimatedSize]. It is important to build an empty list of parents first,
/// so the difference in size of the column gets animated.
class _TweetReplyParents extends StatefulWidget {
  const _TweetReplyParents(this.parents);

  final List<Tweet> parents;

  @override
  _TweetReplyParentsState createState() => _TweetReplyParentsState();
}

class _TweetReplyParentsState extends State<_TweetReplyParents>
    with SingleTickerProviderStateMixin<_TweetReplyParents> {
  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      child: Column(
        children: widget.parents.map((tweet) {
          return TweetTile(tweet: tweet);
        }).toList(),
      ),
    );
  }
}
