<?php

namespace App\Policies;

use App\Models\User;
use Illuminate\Auth\Access\HandlesAuthorization;

class UserPolicy
{
    use HandlesAuthorization;

    /**
     * Determine whether the user can view the model.
     *
     * @param  \App\Models\User  $user
     * @param  \App\Models\User  $model
     * @return \Illuminate\Auth\Access\Response|bool
     */
    public function view(User $user, User $model)
    {
        return ($user->id > 0);
    }

    /**
     * Determine whether the user can update the model.
     *
     * @param  \App\Models\User  $user
     * @param  \App\Models\User  $model
     * @return \Illuminate\Auth\Access\Response|bool
     */
    public function update(User $user, User $model)
    {
        return ($user->id == $model->id || $user->is_admin);
    }

    /**
     * Determine whether the user can delete the model.
     *
     * @param  \App\Models\User  $user
     * @param  \App\Models\User  $model
     * @return \Illuminate\Auth\Access\Response|bool
     */
    public function delete(User $user, User $model)
    {
        return ($user->id == $model->id || $user->is_admin);
    }
	
	public function follow(User $user, User $model)
    {
        return (!($user->followMember->contains($model)) and $user->id != $model->id);
    }
	
	public function unfollow(User $user, User $model)
    {
        return $user->followMember->contains($model);
    }
	
	public function seeFeed(User $user, User $model)
    {
        return $user->id == $model->id;
    }
}
