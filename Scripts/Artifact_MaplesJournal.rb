class Artifact_MaplesJournal < Artifact

  def self.get_base_stats
    return {
      :name       => "Maple's Journal",
      :description => "Grants archive scaling with the number of active synergies " +
        "you have.",
      :cost       => 1,
      :type       => :completed,
      :keys       => ["Book"],
      :impacts    => [
        [Impact, [:ARCHIVE, 20]],
        [Impact_SynCounter, [:ARCHIVE, 10]]
      ],
      :components => ["Warded Tome", "Warded Tome"],
      :back   => [:ARCHIVE]
    }
  end
  
  def self.get_description
    return [
     #"Grants power and multistrike chan",
      "Grants archive scaling with the",
      "your number of active synergies."
    ]
  end
  
end

register_artifact(Artifact_MaplesJournal)