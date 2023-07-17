$states = [undef, false, true]
$states.each |$previous| {
  $states.each |$desired| {
    setter_call { "${previous}_2_${desired}":
      previous_state => $previous,
      desired_state  => $desired,
    }
  }
}
