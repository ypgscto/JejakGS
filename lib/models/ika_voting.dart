import 'json_utils.dart';

class IkaVoting {
  const IkaVoting({
    required this.id,
    required this.title,
    required this.status,
    this.description,
    this.startAt,
    this.endAt,
    this.targetRole,
    this.targetRoleLabel,
    this.statusLabel,
    this.hasVoted = false,
    this.selectedOptionId,
    this.canVote = false,
    this.options = const [],
    this.results,
  });

  final String id;
  final String title;
  final String? description;
  final DateTime? startAt;
  final DateTime? endAt;
  final String? targetRole;
  final String? targetRoleLabel;
  final String status;
  final String? statusLabel;
  final bool hasVoted;
  final String? selectedOptionId;
  final bool canVote;
  final List<IkaVotingOption> options;
  final IkaVotingResult? results;

  bool get canSubmitVote {
    if (hasVoted || options.isEmpty) {
      return false;
    }

    return canVote || status.toLowerCase().trim() == 'active';
  }

  factory IkaVoting.fromJson(Object? value) {
    final json = JsonUtils.asMap(value);
    final resultJson = JsonUtils.asMap(json['results']);

    return IkaVoting(
      id: JsonUtils.string(json, ['id']) ?? '',
      title: JsonUtils.string(json, ['title']) ?? '',
      description: JsonUtils.string(json, ['description']),
      startAt: JsonUtils.dateTime(json, ['start_at', 'startAt']),
      endAt: JsonUtils.dateTime(json, ['end_at', 'endAt']),
      targetRole: JsonUtils.string(json, ['target_role', 'targetRole']),
      targetRoleLabel: JsonUtils.string(json, [
        'target_role_label',
        'targetRoleLabel',
      ]),
      status: JsonUtils.string(json, ['status']) ?? '',
      statusLabel: JsonUtils.string(json, ['status_label', 'statusLabel']),
      hasVoted: JsonUtils.boolean(json, ['has_voted', 'hasVoted']),
      selectedOptionId: JsonUtils.string(json, [
        'selected_option_id',
        'selectedOptionId',
      ]),
      canVote: JsonUtils.boolean(json, ['can_vote', 'canVote']),
      options: JsonUtils.asMapList(
        json['options'],
      ).map(IkaVotingOption.fromJson).toList(),
      results: resultJson.isEmpty ? null : IkaVotingResult.fromJson(resultJson),
    );
  }
}

class IkaVotingOption {
  const IkaVotingOption({
    required this.id,
    required this.text,
    this.description,
  });

  final String id;
  final String text;
  final String? description;

  factory IkaVotingOption.fromJson(Object? value) {
    final json = JsonUtils.asMap(value);

    return IkaVotingOption(
      id: JsonUtils.string(json, ['id']) ?? '',
      text: JsonUtils.string(json, ['option_text', 'text', 'title']) ?? '',
      description: JsonUtils.string(json, [
        'option_description',
        'description',
      ]),
    );
  }
}

class IkaVotingResult {
  const IkaVotingResult({required this.totalVotes, this.options = const []});

  final int totalVotes;
  final List<IkaVotingResultOption> options;

  factory IkaVotingResult.fromJson(Object? value) {
    final json = JsonUtils.asMap(value);

    return IkaVotingResult(
      totalVotes: JsonUtils.integer(json, ['total_votes', 'totalVotes']) ?? 0,
      options: JsonUtils.asMapList(
        json['options'],
      ).map(IkaVotingResultOption.fromJson).toList(),
    );
  }
}

class IkaVotingResultOption {
  const IkaVotingResultOption({
    required this.id,
    required this.text,
    required this.votesCount,
    required this.percentage,
  });

  final String id;
  final String text;
  final int votesCount;
  final double percentage;

  factory IkaVotingResultOption.fromJson(Object? value) {
    final json = JsonUtils.asMap(value);

    return IkaVotingResultOption(
      id: JsonUtils.string(json, ['id']) ?? '',
      text: JsonUtils.string(json, ['option_text', 'text']) ?? '',
      votesCount: JsonUtils.integer(json, ['votes_count', 'votesCount']) ?? 0,
      percentage: JsonUtils.decimal(json, ['percentage']) ?? 0,
    );
  }
}

class IkaVoteReceipt {
  const IkaVoteReceipt({
    required this.votingId,
    required this.optionId,
    this.votedAt,
    this.results,
  });

  final String votingId;
  final String optionId;
  final DateTime? votedAt;
  final IkaVotingResult? results;

  factory IkaVoteReceipt.fromJson(Object? value) {
    final json = JsonUtils.asMap(value);
    final resultJson = JsonUtils.asMap(json['results']);

    return IkaVoteReceipt(
      votingId: JsonUtils.string(json, ['voting_id', 'votingId']) ?? '',
      optionId: JsonUtils.string(json, ['option_id', 'optionId']) ?? '',
      votedAt: JsonUtils.dateTime(json, ['voted_at', 'votedAt']),
      results: resultJson.isEmpty ? null : IkaVotingResult.fromJson(resultJson),
    );
  }
}
