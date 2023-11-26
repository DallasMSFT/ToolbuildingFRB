
Class FRBUser {

	# This is not a great example of a class, but it does show how to use a class.

	# Properties
	hidden [Microsoft.ActiveDirectory.Management.ADUser]$User # The hidden keyword makes the property private.
	hidden [Microsoft.ActiveDirectory.Management.ADGroup]$Group # Just showing that hidden can be used. Get-Member will not show hidden properties unless you use the -Force parameter.

	# Constructors
	FRBUser() {
		# Default constructor
	}
	FRBUser([Microsoft.ActiveDirectory.Management.ADUser]$User, [Microsoft.ActiveDirectory.Management.ADGroup]$Group) {
		# Constructor with parameters

		$this.User = $User
		$this.Group = $Group
	}

	# Methods
	[string] UserName() {
		return $this.User.SamAccountName
	}

	[string] GroupName() {
		return $this.Group.Name
	}

	[string] UserDN() {
		return $this.User.DistinguishedName
	}

	[string] GroupDN() {
		return $this.Group.DistinguishedName
	}

	[string] UserDescription() {
		return $this.User.Description
	}

	[string] GroupDescription() {
		return $this.Group.Description
	}

	[string] UserEmail() {
		return $this.User.EmailAddress
	}

	[string] GroupEmail() {
		return $this.Group.EmailAddress
	}

	# Overload the ToString() method
	[string] ToString() {
		return "User: $($this.UserName()) Group: $($this.GroupName())"
	}

}