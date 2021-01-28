-- Create Check Constraints --

ALTER TABLE Citizenship
ADD CONSTRAINT CitizenNumbers CHECK (CitizenNumbers >= 0);

ALTER TABLE Citizenship
ADD CONSTRAINT CitizenPercents CHECK (CitizenPercents >= 0);

-- View for PublicSchoolTrusteeResult2017 --

CREATE VIEW PublicSchoolTrusteeResult2017_vw AS (
	SELECT DISTINCT CRV.CandidateNames,
			CRV.OfficeTypes,
			CRV.CandidateTypes,
			WC.OldWardIDs,
			CI.FK1_NewWardIDs,
			RSVSRV.VotingStationIDs,
			RSVSRV.VotingStationNames,
			RSVSRV.VotingStationTypes,
			CI.CommunityNames,
			VC.VoteCounts,
			VI.EnumeratedElectorsNumbers,
			VI.VoterTurnouts
	FROM Candidate_Result_vw AS CRV
	INNER JOIN VoteCount AS VC
		ON CRV.CandidateIDs = VC.FK_CandidateIDs
	INNER JOIN RegularSpecialVotingStation_Result_vw AS RSVSRV
		ON RSVSRV.VotingStationIDs = VC.FK2_VotingStationIDs
	INNER JOIN VoterInformation AS VI
		ON VI.FK1_VotingStationIDs = RSVSRV.VotingStationIDs
	INNER JOIN CommunityInformation AS CI
		ON CI.PK_CommunityIDs = RSVSRV.CommunityIDs
	INNER JOIN WardChange AS WC
		ON WC.FK2_NewWardIDs = CI.FK1_NewWardIDs
	WHERE OfficeTypes = 'Public School Trustee');

-- View for Regular/Special Voting Station Results join Table--

CREATE VIEW RegularSpecialVotingStation_Result_vw AS (
	SELECT  RSVSR.VotingStationIDs, 
		VSN.VotingStationNames,
		VST.PK_VotingStationTypeIDs AS VotingStationTypeIDs,
		VST.VotingStationTypes,
		RSVSR.FK7_CommunityIDs AS CommunityIDs
	FROM RegularSpecialVotingStation_Result AS RSVSR
	INNER JOIN VotingStationName AS VSN
		ON VSN.PK_VotingStationIDs = RSVSR.VotingStationIDs
	INNER JOIN VotingStationType AS VST
		ON VST.PK_VotingStationTypeIDs = VSN.FK_VotingStationTypeIDs);