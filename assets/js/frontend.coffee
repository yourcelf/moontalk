#= require 'lib/jquery'

generateScheds = (bestPercentage=0.7, timesPerPerson=3) ->
  # Sanitize number of players
  val = $("#num_players").val()
  num = parseInt val
  if isNaN(num)
    if val != ""
      alert "Invalid number: #{$("#num_players").val()}"
    return null
  else if num < 4
    alert "Minimum 4 players."
    num = 4
    $("#num_players").val(4)

  # Build random times.
  times = [1..7] # More than 7 options are never needed for 70%. Math?!
  choices = []
  ranks = []
  reps = 1
  while choices.length < num * timesPerPerson and times.length > 0
    for rep in [0...reps]
      time = sample(times)
      if time?
        count = Math.max 2, Math.round(bestPercentage * num - reps + 1)
        ranks.push([time, count])
        for j in [0...count]
          choices.push(time)
    reps += reps
  # Trim back to the number of choices to x per person.
  choices = choices.slice(0, num * timesPerPerson)
  
  # Shuffle, distribute.
  shuffle(choices)
  people = ([] for i in [0...num])
  for choice in choices
    j = 0
    while people[j].length >= timesPerPerson or $.inArray(choice, people[j]) != -1
      j += 1
      if j == people.length
        # XXX HACK: avoid the tricky constraint-solving problem of shuffling by
        # just re-running if we screw up.
        return generateScheds(bestPercentage, timesPerPerson)
    people[j].push(choice)
  
  # Display schedules.
  $(".game-assignments").html("<h2>Assignments</h2>")
  ol = $("<ol/>")
  for scheds in people
    scheds.sort (a, b) -> if a > b then 1 else if a < b then -1 else 0
    ol.append $("<li>").html ("#{i}pm" for i in scheds).join(", ")
  $(".game-assignments").append(ol)
  # Ranking of answers:
  results = {}
  for scheds in people
    for time in scheds
      unless results[time] then results[time] = 0
      results[time] += 1
  scores = ([count, time] for time,count of results).sort (a,b) ->
    if a[0] > b[0]
      return -1
    else if b[0] > a[0]
      return 1
    return 0
  $(".scoring").html("<h2>Scoring</h2>")
  ol = $("<ul/>")
  for score in scores
    ol.append $("<li>").html score[1] + "pm (#{score[0]} people available)"
  $(".scoring").append(ol)
    
  $(".game-assignments")[0].scrollIntoView()

  return false

shuffle = (array) ->
  # Randomly shuffle the array in-place.  Fisher-Yates shuffle.
  i = array.length
  while i
    j = parseInt(Math.random() * i)
    [array[j], array[i]] = [array[--i], array[j]]
  return array

sample = (array) ->
  # Destructively remove one random element from the array, and return it.
  i = parseInt(Math.random() * array.length)
  return array.splice(i, 1)[0]

$("form.generate").on 'submit', -> generateScheds() ; return false
