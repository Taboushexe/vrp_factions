ALTER TABLE `vrp_users` ADD (
  `faction` text NOT NULL DEFAULT 'user',
  `isFactionLeader` int(255) NOT NULL DEFAULT 0,
  `factionRank` text NOT NULL DEFAULT 'none'
);